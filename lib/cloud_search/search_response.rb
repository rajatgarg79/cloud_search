module CloudSearch
  class SearchResponse
    attr_accessor :body
    attr_accessor :http_code

    def results
      (_hits and _hits['hit']) or []
    end

    def hits
      (_hits and _hits['found']) or 0
    end

    def found?
      hits >= 1
    end

    private
    def _hits
      body and body['hits']
    end
  end
end
