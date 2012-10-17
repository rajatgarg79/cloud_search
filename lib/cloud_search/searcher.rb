module CloudSearch
  class Searcher

    def search
      response = SearchResponse.new

      EM.run do
        http = EM::HttpRequest.new(build_url).get

        http.callback do
          response.http_code = http.response_header.status 
          response.body = JSON.parse(http.response) 

          EM.stop
        end

        http.errback do
          response.http_code = http.error
          response.body = http.response

          EM.stop
        end
      end

      response
    end

    def query(q)
      @query = q
      self
    end

    def with_fields(*fields)
      @fields = fields
      self
    end

    private 

    def build_url
      url = CloudSearch.config.search_url
      url+= "/#{CloudSearch.config.api_version}"
      url+= "/search"
      url+= "?q=#{CGI.escape(@query)}"
      url+= "&return-fields=#{CGI.escape(@fields.join(","))}" if @fields.any?
    end
  end
end

