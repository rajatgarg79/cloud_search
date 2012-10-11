require "spec_helper"

describe CloudSearch::Search do
  subject { CloudSearch::Search }

  before do
    CloudSearch.configure do |config|
      config.domain_id   = "pl6u4t3elu7dhsbwaqbsy3y6be"
      config.domain_name = "imdb-movies"
    end
  end

  describe ".request" do
    let(:fields) { [:actor, :director, :title, :year, :text_relevance] }

    context "given valid parameters" do
      it "returns http 200 code" do
        VCR.use_cassette("search/request/full") do
          resp, msg = subject.request("star wars", *fields)
          expect(msg).to match(/^200/)
        end
      end

      it "returns one or more results" do
        VCR.use_cassette("search/request/full") do
          resp, msg = subject.request("star wars", *fields)
          expect(resp["hits"]["found"]).to be >= 1
        end
      end
    end

    context "given invalid parameters" do
      it "returns" do

      end
    end
  end
end

