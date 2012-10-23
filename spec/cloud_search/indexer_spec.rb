require 'spec_helper'

describe CloudSearch::Indexer do
  let(:indexer) { described_class.new }

  describe "#documents" do
    it "returns the list of documents to be indexed" do
      doc1 = stub.as_null_object
      doc2 = stub.as_null_object
      indexer << doc1
      indexer << doc2
      expect(indexer.documents).to eq([doc1, doc2])
    end

    it "returns a frozen version of the documents list" do
      expect {
        indexer.documents << stub
      }.to raise_error(RuntimeError)
    end
  end

  describe "#<<" do
    let(:document) { stub :valid? => true }

    it "adds a new item to the list of documents" do
      indexer << document
      expect(indexer.documents).to have(1).item
    end

    it "is aliased to #add" do
      indexer.add document
      expect(indexer.documents).to have(1).item
    end

    it "raises an exception if the document is invalid" do
      expect {
        indexer << stub(:valid? => false, :errors => {})
      }.to raise_error(CloudSearch::InvalidDocument)
    end
  end

  describe "#index" do
    let(:document) { CloudSearch::Document.new(
      :type    => type,
      :id      => 678,
      :version => version,
      :lang    => :en,
      :fields  => {:actor => ["Cassio Marques", "Willian Fernandes"], :director => ["Lucas, George"], :title => "Troy Wars"}
    ) }
    let(:indexer) { described_class.new }

    context "adding a new document" do
      around do |example|
        VCR.use_cassette "index/request/add", &example
      end

      let(:type) { "add" }
      let(:version) { 1 }
      let(:url) { "#{CloudSearch.config.document_url}/documents/batch" }
      let(:json) { [document].to_json }

      it "succeeds" do
        indexer << document
        resp, message = indexer.index
        expect(resp["status"]).to eq("success")
        expect(resp["adds"]).to eq(1)
        expect(resp["deletes"]).to eq(0)
        expect(message).to match(/^200/)
      end

      it "sends http headers with json format info" do
        indexer << document
        RestClient.should_receive(:post).with(url, kind_of(String), {"Content-Type" => "application/json", "Accept" => "application/json" }).and_return(stub(:code => 1, :length => 10, :body => '{}'))
        indexer.index
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
            indexer.index
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
            indexer.index
          }.to raise_error(CloudSearch::MissingConfigurationError, "Missing 'domain_name' configuration parameter")
        end
      end
    end

    context "adding a batch of documents" do
      around do |example|
        VCR.use_cassette "index/request/add_in_batch", &example
      end

      let(:type) { "add" }
      let(:version) { 5 }

      it "succeeds" do
        indexer << document
        document2 = CloudSearch::Document.new :type => type, :version => version, :id => 679, :lang => :en, :fields => {:title => "Fight Club"}
        document3 = CloudSearch::Document.new :type => type, :version => version, :id => 680, :lang => :en, :fields => {:title => "Lord of the Rings"}
        indexer << document2
        indexer << document3
        resp, message = indexer.index
        expect(resp["adds"]).to eq(3)
        expect(resp["status"]).to eq("success")
      end
    end

    context "deleting a document" do
      around do |example|
        VCR.use_cassette "index/request/delete", &example
      end

      let(:type) { "delete" }
      let(:version) { 2 }

      it "succeeds" do
        indexer << document
        resp, message = indexer.index
        expect(resp["status"]).to eq("success")
        expect(resp["adds"]).to eq(0)
        expect(resp["deletes"]).to eq(1)
        expect(message).to match(/^200/)
      end
    end
  end
end
