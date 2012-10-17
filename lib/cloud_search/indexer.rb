module CloudSearch
  class Indexer
    def initialize
      @documents = []
    end

    def <<(document)
      raise InvalidDocument.new(document) unless document.valid?
      @documents << document
    end

    alias :add :<<

    def documents
      @documents.freeze
    end

    def index
      response, message = nil
      EM.run do
        http = EM::HttpRequest.new(url).post :body => documents_json, :head => headers

        http.callback {
          message  = "#{http.response_header.status} - #{http.response.length} bytes\n#{url}\n"
          response = JSON.parse(http.response)

          EM.stop
        }

        http.errback {
          message = "#{url}\n#{http.error}"

          EM.stop
        }
      end

      [response, message]
    end

    private

    def headers
      {"Content-Type" => "application/json"}
    end

    def documents_json
      JSON.unparse(@documents.map(&:as_json))
    end

    def url
      "#{CloudSearch.config.document_url}/documents/batch"
    end
  end
end
