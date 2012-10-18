require "singleton"

module CloudSearch
  class MissingConfigurationError < StandardError
    def initialize(parameter_name)
      super "Missing '#{parameter_name}' configuration parameter"
    end
  end

  module ConfigurationChecking
    private

    def check_configuration_parameters
      raise MissingConfigurationError.new("domain_id") if CloudSearch.config.domain_id.nil?
      raise MissingConfigurationError.new("domain_name") if CloudSearch.config.domain_name.nil?
    end
  end

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
      @document_url ||= "http://doc-#{self.domain_name}-#{self.domain_id}.#{self.region}.cloudsearch.amazonaws.com/#{self.api_version}"
    end

    def region
      @region ||= "us-east-1"
    end

    def search_url
      @search_url ||= "http://search-#{self.domain_name}-#{self.domain_id}.#{self.region}.cloudsearch.amazonaws.com/#{self.api_version}"
    end
  end
end

