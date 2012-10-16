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
        url = CloudSearch.config.document_url
        url+= "/documents/batch"

        http = EM::HttpRequest.new(url).post :body => JSON.unparse(@documents.map(&:as_json)), :head => {"Content-Type" => "application/json"}

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
  end
end
