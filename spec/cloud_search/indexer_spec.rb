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
end
