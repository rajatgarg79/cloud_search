module CloudSearch
  class SearchResponse
    attr_reader   :body
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

    def body=(body)
      @body = body
      calculate_pages
      @body
    end

    def items_per_page
      @items_per_page or 10
    end

    alias :page_size :items_per_page
    alias :total_entries :hits

    attr_writer :items_per_page
    attr_reader :current_page
    attr_reader :total_pages

    def offset
      return 0 unless found?
      (@current_page - 1) * items_per_page
    end

    private
    def calculate_pages
      num_full_pages = hits / items_per_page
      @total_pages   = hits % items_per_page > 0 ? num_full_pages + 1 : num_full_pages
      @total_pages   = 1 if @total_pages == 0

      start = (_hits and _hits["start"]) || 0
      @current_page = (start / items_per_page) + 1
      @current_page = @total_pages if @current_page > @total_pages
    end

    def _hits
      body and body['hits']
    end
  end
end
