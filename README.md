[![Build Status](https://secure.travis-ci.org/willian/cloud_search.png)](http://travis-ci.org/willian/cloud_search)

# CloudSearch

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem "cloud_search"

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install cloud_search

## Usage

The example bellow uses the Amazon's example database called `imdb-movies`:

```ruby
# Use your AWS CloudSearch configuration
CloudSearch.configure do |config|
  config.domain_id   = "pl6u4t3elu7dhsbwaqbsy3y6be"
  config.domain_name = "imdb-movies"
end

# Search for 'star wars' on 'imdb-movies'
resp, msg = CloudSearch::Search.request("star wars",
                                        :actor,
                                        :director,
                                        :title,
                                        :year,
                                        :text_relevance)

# Or you can search using part of the name
resp, msg = CloudSearch::Search.request("matri*",
                                        :actor,
                                        :title,
                                        :year,
                                        :text_relevance)

# Number of results
resp["found"]

resp["hit"].each do |result|
  movie = result["data"]

  # List of actors on the movie
  movie["actor"]

  # Movie's name
  movie["title"]

  # A rank number used to sort the results
  # The `text_relevance` key is added by AMS CloudSearch
  movie["text_relevance"]
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

