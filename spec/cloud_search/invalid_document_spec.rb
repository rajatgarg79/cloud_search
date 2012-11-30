require 'spec_helper'

describe CloudSearch::InvalidDocument do
  let(:document) { CloudSearch::Document.new }

  it "has a message with the document errors" do
    expect(described_class.new(document).message).to eq("id: can't be blank; version: can't be blank; type: can't be blank")
  end
end
