require 'uri'

module CloudSearch
  class Searcher
    include ::CloudSearch::ConfigurationChecking

    attr_reader :weights

    def initialize
      @response = SearchResponse.new
      @filters  = []
      @facets   = []
      @fields   = []
      @facets_constraints = {}
    end

    def search
	Rails.logger.info url
      cloud_search_response = RestClient.get url
      @response.http_code   = cloud_search_response.code
      @response.body        = cloud_search_response.body

      @response
    end

    def with_query(query)
      @query = query
      self
    end

    def with_filter(filter)
      @filters << filter
      self
    end

    def with_facets(facets)
      @facets = facets
      self
    end

    def with_facet_constraints(facets_constraints)
      @facets_constraints = facets_constraints
      self
    end

    def as_boolean_query
      @boolean = true
      self
    end
    def as_custom_query_for_supplier
	 @custom = true
      self
    end
    def ranked_by(rank_expression)
      @rank = rank_expression
      self
    end

    def query
      return '' unless @query
      URI.escape(@query).gsub('&', '%26')
#      URI.parse(URI.encode(URI.escape(@query).gsub('&', '%26')))
    end

    def boolean_query?
      !!@boolean
    end
    def custom_query_for_supplier?
	!!@custom

   end
   def with_query_with_constraints(const)
		@custom_for_category_params= const
	self
  end
	def with_query_with_search(search_const)
		@custom_for_search_params = search_const
	self
  end
	
   
    def with_fields(*fields)
      @fields += fields
      self
    end

    def with_items_per_page(items_per_page)
      @response.items_per_page = items_per_page
      self
    end

    def items_per_page
      @response.items_per_page
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
      (items_per_page * (page_number - 1))
    end

    def url
      check_configuration_parameters
	if @facets.any?
	facet = ""
	@facets.each{|f|
#		if f == "price" || f== "discount"
#		facet = facet + "&" + "facet.#{f}={sort:'count'}"
#		elsif f.include?("discount_with_bucket")
#			next
#		elsif f.include?("price_with_bucket")
#			next
#		else	
	 facet = facet + "&" + "facet.#{f}={sort:"+'"count"'+", size:50}"

#		end
		}
	end
	puts facet
	"#{CloudSearch.config.search_url}/search".tap do |u|
        u.concat("?#{query_parameter}&size=#{items_per_page}&start=#{start}")
        u.concat("&return=#{URI.escape(@fields.join(","))}") if @fields.any?
        u.concat("&#{filter_expression}") if @filters.any?
        u.concat("#{URI.escape(facet)}") if @facets.any?
        u.concat(@facets_constraints.map do |k,v|
          values = v.respond_to?(:map) ? v.map{ |i| "'#{i}'" } : ["'#{v}'"]
          "&facet-#{k}-constraints=#{values.join(',')}"
        end.join('&'))
        u.concat("&rank=#{@rank}") if @rank
      end
    end

    private

    def query_parameter
	      if boolean_query? 
			return  "q.parser=structured&q=#{query}" 



		elsif	custom_query_for_supplier? 
			 if !query.blank?
                        query_pa= query.split("%23and%23")
                        end
                        return  "q=(and+(term+field%3D#{query_pa[1]}+'#{query_pa[0]}'))&q.parser=structured"



		elsif  !@custom_for_category_params.blank?
		
			custom_url = "q="
			catg = @custom_for_category_params["category_id"]
			if @custom_for_category_params.keys.size> 2
			custom_url = custom_url + "(and+category_id_array:'#{catg}'+(and+"
			elsif @custom_for_category_params.keys.size == 2
			return	custom_url = custom_url + "(and+category_id_array:'#{catg}')&q.parser=structured"
			end
			@custom_for_category_params.each{|key,value_array|
					if key != "category_id" && value_array.class == Array && key != "price" && key != "discount" && key != "rating"
						 custom_url = custom_url + "(or+"
						value_array.each{|value|
						value.each{|to_search|
							custom_url = custom_url + URI.escape("#{key}:'#{to_search}'+")
						}
						}
						custom_url = custom_url + ")+"
					end
				}
			    array = Array.new
                        array = ["price","discount","rating"]
                        array.each{|ranges_field|
                         if @custom_for_category_params.key?(ranges_field)
                                              value_array = @custom_for_category_params[ranges_field]
                                                value_array.each{|value|
                                                min_max = value.split(',')
                                                if min_max.size == 2
                                                min = min_max.first
                                                max = min_max.last
                                                else
							if value[0] == ','
                                                                min = ""
                                                                max = min_max.first
                                                        elsif
                                                                min =  min_max.first
                                                                max = ""
                                                        end

                                                end
                                                if ranges_field != "rating"
                                                custom_url = custom_url + "(range+field%3D#{ranges_field}+%7B"+URI.escape("#{min},#{max}")+"%7D)+"
                                                else
                                                custom_url = custom_url + "(range+field%3D#{ranges_field}+["+URI.escape("#{min},#{max}")+"%7D)+"
                                                end
                                                }

                        end
                        }
                        custom_url = custom_url + "))&q.parser=structured"
                        return custom_url

		elsif !@custom_for_search_params.blank?

			  Rails.logger.info @custom_for_search_params
                        custom_url = "q="
                        key_word = @custom_for_search_params["query"]
			if @custom_for_search_params.keys.size > 1
                        custom_url = custom_url + "(and+(term+'"+URI.escape("#{key_word}")+"')+(and+"
			elsif @custom_for_search_params.keys.size == 1
			return custom_url = custom_url + "(and+(term+'"+URI.escape("#{key_word}")+"'))&q.parser=structured&q.options=%7Bfields:['name','isbn13','supplier','brand','text_to_search']%7D"
			end
                        @custom_for_search_params.each{|key,value_array|
                                        if key != "category_id" && value_array.class == Array && key != "price" && key != "discount" && key != "rating"
						custom_url = custom_url + "(or+"
                                                value_array.each{|value|
                                                value.each{|to_search|
                                                        custom_url = custom_url + URI.escape("#{key}:'#{to_search}'+")
                                                }
                                                }
						custom_url = custom_url + ")+"
                                        end
                                }
			array = Array.new
			array = ["price","discount","rating"]
			array.each{|ranges_field|
                         if @custom_for_search_params.key?(ranges_field)
					      value_array = @custom_for_search_params[ranges_field]
                                                value_array.each{|value|
                                                min_max = value.split(',')
						if min_max.size == 2
                                                min = min_max.first
                                                max = min_max.last
						else
							
							 if value[0] == ','
                                                                min = ""
                                                                max = min_max.first
                                                        elsif
                                                                min =  min_max.first
                                                                max = ""
                                                        end

						end
                                                if ranges_field != "rating"
                                                custom_url = custom_url + "(range+field%3D#{ranges_field}+%7B"+URI.escape("#{min},#{max}")+"%7D)+"
                                                else
                                                custom_url = custom_url + "(range+field%3D#{ranges_field}+["+URI.escape("#{min},#{max}")+"%7D)+"
                                                end
                                                }
				
			end
			}
                        custom_url = custom_url + "))&q.parser=structured&q.options=%7Bfields:['name','isbn13','supplier','brand','text_to_search']%7D"
                        return custom_url
		




		elsif
			@facets.each{|f|
                if f.include?("price_with_bucket")
                        range = f.split('/')
#                        facet = facet + "&" + "facet.discount={buckets:[#{range[-2]},#{range[-1]}]}"
			return "q=(and+(term+'#{query}')+(range+field%3Dprice+{#{range[-2]},#{range[-1]}}))&q.parser=structured"
                elsif f.include?("discount_with_bucket")
                        range = f.split('/')
                        facet = facet + "&" + "facet.price={buckets:[#{range[-2]},#{range[-1]}]}"
		end
                }
			return "q=(and+(term+'#{query}'))&q.parser=structured"
			return  "q=#{query}"	
	    end
	end

    def filter_expression
      @filters.join("&")
    end
  end
end



