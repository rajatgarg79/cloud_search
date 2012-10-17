require "spec_helper"

describe CloudSearch::Searcher do
  subject { described_class.new }

  describe "#search" do
    before do
      subject
        .with_fields(:actor, :director, :title, :year, :text_relevance)
        .query("star wars")
    end

    around { |example| VCR.use_cassette "search/request/full", &example }

    context "given valid parameters" do
      it "returns http 200 code" do
        resp = subject.search
        resp.http_code.should == 200
      end

      it "has found results" do
        resp = subject.search
        resp.should be_found
      end

      it "returns number of hits" do
        resp = subject.search
        expect(resp.hits).to be == 7
      end

      it "returns Episode II" do
        resp = subject.search
        resp.results.inject([]){|acc, i| acc << i['data']['title']}.flatten
        .should include "Star Wars: Episode II - Attack of the Clones"
      end
    end
  end
end

