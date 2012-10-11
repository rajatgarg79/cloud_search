require "em-http"
require "cloud_search/version"

module CloudSearch
  autoload :Config, "cloud_search/config"
  autoload :Search, "cloud_search/search"

  def self.config
    Config.instance
  end

  def self.configure(&block)
    block.call(self.config)
  end
end

