require "em-http"
require "json"
require "cloud_search/version"

module CloudSearch
  autoload :Config, "cloud_search/config"
  autoload :Search, "cloud_search/search"
  autoload :Document, "cloud_search/document"

  def self.config
    Config.instance
  end

  def self.configure(&block)
    block.call(self.config)
  end
end

