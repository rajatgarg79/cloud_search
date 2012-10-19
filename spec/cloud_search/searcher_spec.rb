require "spec_helper"

describe CloudSearch::Searcher do
  subject { described_class.new }

  let(:url_prefix) do
    "#{CloudSearch.config.search_url}/search?"
  end

  describe "#query" do
    it "returns default query" do
      subject.query.should == ""
    end

    it "returns default query when it's tried to set nil value" do
      subject.with_query(nil)
      subject.query.should == ""
    end
  end

  describe "#with_query" do
    it "returns #{described_class} instance" do
      subject.with_query("foo").should == subject
    end

    it "setup query" do
      subject.with_query("foo")
      subject.query.should == "foo"
    end
  end

  describe "#with_boolean_query" do
    it "sets the query mode to 'boolean'" do
      subject.with_boolean_query("year:2000")
      subject.should be_boolean_query
    end

    it "returns the searcher instance" do
      subject.with_boolean_query("year:2000").should == subject
    end

    it "sets the query term" do
      subject.with_boolean_query("year:2000")
      subject.query.should == "year:2000"
    end

    it "uses 'bq' to specify the query in the URL" do
      subject.with_boolean_query("year:2000")
      subject.url.should == "#{url_prefix}bq=year:2000&size=10&start=0"
    end
  end

  describe "#with_fields" do
    it "returns #{described_class} instance" do
      subject.with_fields(:foo).should == subject
    end

    it "setup more thane one value" do
      subject.with_fields(:foo, :bar, :foobar)
    end
  end

  describe "#items_per_page" do
    it "returns default items_per_page" do
      subject.items_per_page.should == 10
    end

    it "returns default items per page when it's tried to set nil value" do
      subject.with_items_per_page(nil)
      subject.items_per_page.should == 10
    end
  end

  describe "#with_items_per_page" do
    it "returns #{described_class} instance" do
      subject.with_items_per_page(nil).should == subject
    end

    it "setup items per page" do
      subject.with_items_per_page(100)
      subject.items_per_page.should == 100
    end
  end

  describe "#page_number" do
    it "returns default page number" do
      subject.page_number.should == 1
    end

    it "returns default page number when it's tried to set nil value" do
      subject.at_page(nil)
      subject.page_number.should == 1
    end
  end

  describe "#at_page" do
    it "returns #{described_class} instance" do
      subject.at_page(1).should == subject
    end

    it "setup page number" do
      subject.at_page(2)
      subject.page_number.should == 2
    end

    it "ensure page is greater than 1" do
      subject.at_page(0)
      subject.page_number.should == 1

      subject.at_page(-1)
      subject.page_number.should == 1
    end
  end

  describe "#start" do
    it "returns default start index number to search" do
      subject.start.should == 0
    end

    it "returns start index 19 for page 2" do
      subject.at_page(2)
      subject.start.should == 11
    end
  end

  describe "#url" do
    it "returns default cloud search url" do
      subject.url.should == "#{url_prefix}q=&size=10&start=0"
    end

    it "returns cloud search url with foo query" do
      subject.with_query("foo").url.should == "#{url_prefix}q=foo&size=10&start=0"
    end

    it "returns cloud search url with foo query" do
      subject.with_query("f&oo").url.should == "#{url_prefix}q=f%26oo&size=10&start=0"
    end

    it "returns cloud search url with foo* query" do
      subject.with_query("foo*").url.should == "#{url_prefix}q=foo*&size=10&start=0"
    end

    it "returns cloud search url with size equals 20" do
      subject.with_items_per_page(20).url.should == "#{url_prefix}q=&size=20&start=0"
    end

    it "returns cloud search url with start at 19" do
      subject.at_page(2).url.should == "#{url_prefix}q=&size=10&start=11"
    end

    it "returns cloud search url with foo and bar fields" do
      subject.with_fields(:foo, :bar).url.should == "#{url_prefix}q=&size=10&start=0&return-fields=foo,bar"
    end
  end

  describe "#search" do
    before do
      subject
      .with_fields(:actor, :director, :title, :year, :text_relevance)
      .with_query("star wars")
    end

    context "when the domain id was not configured" do
      around do |example|
        domain_id = CloudSearch.config.domain_id
        CloudSearch.config.domain_id = nil
        example.call
        CloudSearch.config.domain_id = domain_id
      end

      it "raises an error" do
        expect {
          subject.search
        }.to raise_error(CloudSearch::MissingConfigurationError, "Missing 'domain_id' configuration parameter")
      end
    end

    context "when the domain name was not configured" do
      around do |example|
        domain_name = CloudSearch.config.domain_name
        CloudSearch.config.domain_name = nil
        example.call
        CloudSearch.config.domain_name = domain_name
      end

      it "raises an error" do
        expect {
          subject.search
        }.to raise_error(CloudSearch::MissingConfigurationError, "Missing 'domain_name' configuration parameter")
      end
    end

    context "when search" do
      around { |example| VCR.use_cassette "search/request/full", &example }

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
        resp.results.map{ |item| item['data']['title'] }.flatten
        .should include "Star Wars: Episode II - Attack of the Clones"
      end
    end

    context "when paginate result" do
      before do
        subject
        .with_fields(:actor, :director, :title, :year, :text_relevance)
        .with_query("star wars")
      end

      it "returns first page" do
        VCR.use_cassette "search/request/paginated_first_page" do
          subject.with_items_per_page(4)
          subject.at_page(1)
          resp = subject.search
          resp.results.map{ |item| item['data']['title'] }.flatten
          .should include "Star Wars: Episode II - Attack of the Clones"
        end
      end

      it "returns second page" do
        VCR.use_cassette "search/request/paginated_second_page" do
          subject.with_items_per_page(4)
          subject.at_page(2)
          resp = subject.search
          resp.results.map{ |item| item['data']['title'] }.flatten
          .should include "Star Wars: Episode III - Revenge of the Sith"
        end
      end
    end
  end
end

