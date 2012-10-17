require "spec_helper"

describe CloudSearch::Config do
  subject { CloudSearch::Config.instance }

  before do
    CloudSearch.configure do |config|
      config.domain_id   = "pl6u4t3elu7dhsbwaqbsy3y6be"
      config.domain_name = "imdb-movies"
    end
  end

  describe "after set some configurations" do
    it { expect(subject.api_version).to eql("2011-02-01") }
    it { expect(subject.configuration_url).to eql("https://cloudsearch.us-east-1.amazonaws.com") }
    it { expect(subject.domain_id).to eql("pl6u4t3elu7dhsbwaqbsy3y6be") }
    it { expect(subject.domain_name).to eql("imdb-movies") }
    it { expect(subject.document_url).to eql("http://doc-imdb-movies-pl6u4t3elu7dhsbwaqbsy3y6be.us-east-1.cloudsearch.amazonaws.com/2011-02-01") }
    it { expect(subject.region).to eql("us-east-1") }
    it { expect(subject.search_url).to eql("http://search-imdb-movies-pl6u4t3elu7dhsbwaqbsy3y6be.us-east-1.cloudsearch.amazonaws.com/2011-02-01") }
  end
end

