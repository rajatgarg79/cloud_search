require "bundler"
Bundler.require(:default, :development)

require "simplecov"
SimpleCov.start

require "cloud_search"

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each do |file|
  require file
end

