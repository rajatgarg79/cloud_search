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

### Use your AWS CloudSearch configuration
``` ruby
CloudSearch.configure do |config|
  config.domain_id   = "pl6u4t3elu7dhsbwaqbsy3y6be"
  config.domain_name = "imdb-movies"
end
```

### Search for 'star wars' on 'imdb-movies'
``` ruby
search = CloudSearch::Search.new
resp   = search.with_fields(:actor, :director, :title, :year, :text_relevance)
      .with_query("star wars")
      .search
```

### Or you can search using part of the name
``` ruby
search = CloudSearch::Search.new
resp   = search.with_fields(:actor, :director, :title, :year, :text_relevance)
      .with_query("matri*")
      .search
```

## Results
``` ruby
resp.results.each do |result|
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

## Pagination

The results you get back are (currently) API-compatible with will\_paginate:

``` ruby
search = CloudSearch::Search.new
resp   = search.with_fields(:actor, :director, :title, :year, :text_relevance)
      .with_query("star wars")
      .with_items_per_page(30)
      .at_page(10)
      .search

resp.total_entries #=> 5000
resp.total_pages   #=> 167
resp.current_page  #=> 10
resp.offset        #=> 300
resp.page_size     #=> 30
```

## Indexing documents

``` ruby
document = CloudSearch::Document.new :type => "add", # or "delete"
                                     :version => 123,
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

