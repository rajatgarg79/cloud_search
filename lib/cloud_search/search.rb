module CloudSearch
  class Search
    def self.request(query, *fields)
      response, message = nil

      EM.run do
        url = CloudSearch.config.search_url
        url+= "/#{CloudSearch.config.api_version}"
        url+= "/search"
        url+= "?q=#{CGI.escape(query)}"
        url+= "&return-fields=#{CGI.escape(fields.join(","))}" if fields.any?

        http = EM::HttpRequest.new(url).get

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

