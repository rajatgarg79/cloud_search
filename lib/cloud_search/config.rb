require "singleton"

module CloudSearch
  class Config
    include Singleton

    attr_accessor :api_version
    attr_accessor :configuration_url
    attr_accessor :domain_id
    attr_accessor :domain_name
    attr_accessor :document_url
    attr_accessor :region
    attr_accessor :search_url

    def api_version
      @api_version ||= "2011-02-01"
    end

    def configuration_url
      @configuration_url ||= "https://cloudsearch.#{self.region}.amazonaws.com"
    end

    def document_url
      @document_url ||= "http://doc-#{self.domain_name}-#{self.domain_id}.#{self.region}.cloudsearch.amazonaws.com"
    end

    def region
      @region ||= "us-east-1"
    end

    def search_url
      @search_url ||= "http://search-#{self.domain_name}-#{self.domain_id}.#{self.region}.cloudsearch.amazonaws.com"
    end
  end
end

