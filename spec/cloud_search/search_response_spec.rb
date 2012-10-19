require "spec_helper"

describe CloudSearch::SearchResponse do
  subject { described_class.new }

  context "when there are results" do
    before do
      subject.body = YAML.load_file File.expand_path("../../fixtures/full.yml", __FILE__)
    end

    describe "#results" do
      it "list matched documents" do
        subject.results.map{ |item| item['data']['title'] }.flatten
        .should == ["Star Wars: The Clone Wars",
                    "Star Wars",
                    "Star Wars: Episode II - Attack of the Clones",
                    "Star Wars: Episode V - The Empire Strikes Back",
                    "Star Wars: Episode VI - Return of the Jedi",
                    "Star Wars: Episode I - The Phantom Menace",
                    "Star Wars: Episode III - Revenge of the Sith"]
      end
    end

    describe "#hits" do
      it "returns number of hits" do
        subject.hits.should == 7
      end
    end

    describe "#total_entries" do
      it "returns same value from hits" do
        subject.hits.should == subject.total_entries
      end
    end

    describe "#found?" do
      it "returns true when found documents" do
        subject.should be_found
      end
    end

    describe "#any?" do
      it "returns true when has found results" do
        subject.should be_any
      end
    end

    describe "#items_per_page" do
      it "returns items per page as default 10" do
        subject.items_per_page.should == 10
      end
    end

    describe "#page_size" do
      it "returns number of items per page" do
        subject.items_per_page.should == subject.items_per_page
      end
    end

    describe "#offset" do
      it "returns offset as default 0" do
        subject.offset.should == 0
      end
    end
  end

  context "when there aren't results" do
    before do
      subject.body = {}
    end

    describe "#results" do
      it "list matched documents" do
        subject.results.size.should == 0
      end
    end

    describe "#hits" do
      it "returns number of hits" do
        subject.hits.should == 0
      end
    end

    describe "#found?" do
      it "returns false when not found documents" do
        subject.should_not be_found
      end
    end

    describe "#items_per_page" do
      it "returns items per page" do
        subject.items_per_page.should == 10
      end
    end

    describe "#page_size" do
      it "returns number of items per page" do
        subject.items_per_page.should == subject.items_per_page
      end
    end

    describe "#offset" do
      it "returns offset" do
        subject.offset.should == 0
      end
    end
  end

  context "pagination" do
    let(:seven_hits) { YAML.load_file File.expand_path("../../fixtures/full.yml", __FILE__) }

    it "returns number of pages based on hits" do
      subject.items_per_page = 8
      subject.body = seven_hits
      subject.total_pages.should == 1

      subject.items_per_page = 7
      subject.body = seven_hits
      subject.total_pages.should == 1

      subject.items_per_page = 6
      subject.body = seven_hits
      subject.total_pages.should == 2

      subject.items_per_page = 5
      subject.body = seven_hits
      subject.total_pages.should == 2

      subject.items_per_page = 4
      subject.body = seven_hits
      subject.total_pages.should == 2

      subject.items_per_page = 3
      subject.body = seven_hits
      subject.total_pages.should == 3

      subject.items_per_page = 2
      subject.body = seven_hits
      subject.total_pages.should == 4

      subject.items_per_page = 1
      subject.body = seven_hits
      subject.total_pages.should == 7
    end

    it "returns current page based on start and items per page" do
      subject.items_per_page = 3
      seven_hits['hits']['start'] = nil
      subject.body = seven_hits
      subject.current_page.should == 1

      subject.items_per_page = 3
      seven_hits['hits']['start'] = 0
      subject.body = seven_hits
      subject.current_page.should == 1

      subject.items_per_page = 3
      seven_hits['hits']['start'] = 2
      subject.body = seven_hits
      subject.current_page.should == 1

      subject.items_per_page = 3
      seven_hits['hits']['start'] = 3
      subject.body = seven_hits
      subject.current_page.should == 2

      subject.items_per_page = 3
      seven_hits['hits']['start'] = 4
      subject.body = seven_hits
      subject.current_page.should == 2

      subject.items_per_page = 3
      seven_hits['hits']['start'] = 5
      subject.body = seven_hits
      subject.current_page.should == 2

      subject.items_per_page = 3
      seven_hits['hits']['start'] = 6
      subject.body = seven_hits
      subject.current_page.should == 3
    end

    it "calculates offset based on current page and items_per_page" do
      subject.items_per_page = 3
      seven_hits['hits']['start'] = nil
      subject.body = seven_hits
      subject.offset.should == 0

      subject.items_per_page = 3
      seven_hits['hits']['start'] = 0
      subject.body = seven_hits
      subject.offset.should == 0

      subject.items_per_page = 3
      seven_hits['hits']['start'] = 2
      subject.body = seven_hits
      subject.offset.should == 0

      subject.items_per_page = 3
      seven_hits['hits']['start'] = 3
      subject.body = seven_hits
      subject.offset.should == 3

      subject.items_per_page = 3
      seven_hits['hits']['start'] = 4
      subject.body = seven_hits
      subject.offset.should == 3

      subject.items_per_page = 3
      seven_hits['hits']['start'] = 5
      subject.body = seven_hits
      subject.offset.should == 3

      subject.items_per_page = 3
      seven_hits['hits']['start'] = 6
      subject.body = seven_hits
      subject.offset.should == 6
    end
  end
end
