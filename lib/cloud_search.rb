require "em-http"
require "json"
require "cloud_search/version"

module CloudSearch
  autoload :Config, "cloud_search/config"
  autoload :Search, "cloud_search/search"
  autoload :Indexer, "cloud_search/indexer"
  autoload :Document, "cloud_search/document"
  autoload :InvalidDocument, "cloud_search/invalid_document"

  def self.config
    Config.instance
  end

  def self.configure(&block)
    block.call(self.config)
  end
end

