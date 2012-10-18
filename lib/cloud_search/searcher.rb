module CloudSearch
  class Searcher
    include ConfigurationChecking

    def search
      response = SearchResponse.new

      EM.run do
        http = EM::HttpRequest.new(url).get

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

      response.items_per_page = items_per_page
      response
    end

    def with_query(query)
      @query = query
      self
    end

    def with_boolean_query(query)
      @boolean = true
      with_query query
      self
    end

    def query
      @query or ''
    end

    def boolean_query?
      !!@boolean
    end

    def with_fields(*fields)
      @fields = fields
      self
    end

    def with_items_per_page(items_per_page)
      @items_per_page = items_per_page
      self
    end

    def items_per_page
      @items_per_page or 10
    end

    def at_page(page)
      @page_number = (page && page < 1) ? 1 : page
      self
    end

    def page_number
      @page_number or 1
    end

    def start
      return 0 if page_number <= 1
      (items_per_page * page_number) - 1
    end

    def url
      check_configuration_parameters

      "#{CloudSearch.config.search_url}/search".tap do |u|
        u.concat("?#{query_parameter}=#{CGI.escape(query)}&size=#{items_per_page}&start=#{start}")
        u.concat("&return-fields=#{CGI.escape(@fields.join(","))}") unless @fields.nil? or @fields.empty?
      end
    end

    private

    def query_parameter
      boolean_query? ? "bq" : "q"
    end
  end
end

