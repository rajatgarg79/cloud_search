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
search = CloudSearch::Search.new
resp   = search.with_fields(:actor, :director, :title, :year, :text_relevance)
      .query("star wars")
      .request

# Or you can search using part of the name
search = CloudSearch::Search.new
resp   = search.with_fields(:actor, :director, :title, :year, :text_relevance)
      .query("matri*")
      .request

# Number of results
resp.hits

# Results
res.results.each do |result|
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

## Indexing documents

``` ruby
document = CloudSearch::Document.new :type => "add", # or "delete"
                                     :version => version,
                                     :id => 680, :lang => :en,
                                     :fields => {:title => "Lord of the Rings"}

indexer = CloudSearch::Indexer.new
indexer << document # add as many documents as you want
indexer.index
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

