require "spec_helper"

describe CloudSearch::Search do
  subject { CloudSearch::Search.new }

  describe "#request" do
    before do
      subject
        .with_fields(:actor, :director, :title, :year, :text_relevance)
        .query("star wars")
    end

    context "given valid parameters" do
      it "returns http 200 code" do
        VCR.use_cassette("search/request/full") do
          resp = subject.request
          resp.http_code.should == 200
        end
      end

      it "has found results" do
        VCR.use_cassette("search/request/full") do
          resp = subject.request
          resp.should be_found
        end
      end

      it "returns number of hits" do
        VCR.use_cassette("search/request/full") do
          resp = subject.request
          expect(resp.hits).to be == 7
        end
      end

      it "returns Episode II" do
        VCR.use_cassette("search/request/full") do
          resp = subject.request
          resp.results.inject([]){|acc, i| acc << i['data']['title']}.flatten
          .should include "Star Wars: Episode II - Attack of the Clones"
        end
      end
    end

    context "given invalid parameters" do
      it "returns" do
        
      end
    end
  end
end

