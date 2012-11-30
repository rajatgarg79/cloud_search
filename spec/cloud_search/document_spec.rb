# encoding: utf-8

require "spec_helper"

describe CloudSearch::Document do
  it "has a 'id' attribute" do
    expect(described_class.new(:id => 123).id).to eq("123")
  end

  it "has a 'type' attribute" do
    expect(described_class.new(:type => "add").type).to eq("add")
  end

  it "has a 'version' attribute" do
    expect(described_class.new(:version => 1234).version).to eq(1234)
  end

  it "has a 'lang' attribute" do
    expect(described_class.new(:lang => "en").lang).to eq("en")
  end

  it "has a 'fields' attribute" do
    expect(described_class.new(:fields => {:foo => "bar"}).fields).to eq(:foo => "bar")
  end

  it "clears errors between validations" do
    document = described_class.new :id => nil
    expect(document).to_not be_valid
    document.id = "123"
    document.valid?
    expect(document.errors[:id]).to be_nil
  end

  context "id validation" do
    it "is invalid without an id" do
      document = described_class.new
      document.valid?
      expect(document.errors[:id]).to eq(["can't be blank"])
    end

    %w(- ? A & * ç à @ % $ ! = +).each do |char|
      it "is invalid containing #{char}" do
        document = described_class.new :id => "1#{char}2"
        document.valid?
        expect(document.errors[:id]).to eq(["is invalid"])
      end
    end

    it "is invalid starting with an '_'" do
      document = described_class.new :id => "_abc"
      document.valid?
      expect(document.errors[:id]).to eq(["is invalid"])
    end

    it "is invalid with a string containing only spaces" do
      document = described_class.new :id => " "
      document.valid?
      expect(document.errors[:id]).to eq(["can't be blank"])
    end

    it "is valid with a valid id" do
      document = described_class.new :id => "507c54a44a42c408f4000001"
      document.valid?
      expect(document.errors[:id]).to be_nil
    end

    it "is valid with integers" do
      document = described_class.new :id => 123
      document.valid?
      expect(document.errors[:id]).to be_nil
    end

    it "converts integers to strings" do
      expect(described_class.new(:id => 123).id).to eq("123")
    end
  end

  context "version validation" do
    it "is invalid with a non numeric value" do
      document = described_class.new :version => "123a3545656"
      document.valid?
      expect(document.errors[:version]).to eq(["is invalid"])
    end

    it "is invalid with a nil value" do
      document = described_class.new :version => nil
      document.valid?
      expect(document.errors[:version]).to eq(["can't be blank"])
    end

    it "converts strings to integers" do
      expect(described_class.new(:version => "123").version).to eq(123)
    end

    it "does not convert strings to integers if they contain non numerical characters" do
      expect(described_class.new(:version => "123abc567").version).to eq("123abc567")
    end

    it "is invalid if value is greater than CloudSearch::Document::MAX_VERSION" do
      document = described_class.new :version => 4294967296
      document.valid?
      expect(document.errors[:version]).to eq(["must be less than 4294967296"])
    end

    it "is valid with integers greater than zero and less or equal to CloudSearch::Document::MAX_VERSION" do
      document = described_class.new :version => 4294967295
      document.valid?
      expect(document.errors[:version]).to be_nil
    end
  end

  context "type validation" do
    it "is valid if type is 'add'" do
      document = described_class.new :type => "add"
      document.valid?
      expect(document.errors[:type]).to be_nil
    end

    it "is valid if type is 'delete'" do
      document = described_class.new :type => "delete"
      document.valid?
      expect(document.errors[:type]).to be_nil
    end

    it "is invalid if type is anything else" do
      document = described_class.new :type => "wrong"
      document.valid?
      expect(document.errors[:type]).to eq(["is invalid"])
    end

    it "is invalid if type is nil" do
      document = described_class.new :type => nil
      document.valid?
      expect(document.errors[:type]).to eq(["can't be blank"])
    end

    it "is invalid if type is a blank string" do
      document = described_class.new :type => "   "
      document.valid?
      expect(document.errors[:type]).to eq(["can't be blank"])
    end
  end

  context "lang validation" do
    context "when type is 'add'" do
      it "is invalid if lang is nil" do
        document = described_class.new :lang => nil, :type => "add"
        document.valid?
        expect(document.errors[:lang]).to eql(["can't be blank"])
      end

      it "is invalid if lang contains digits" do
        document = described_class.new :lang => "a1", :type => "add"
        document.valid?
        expect(document.errors[:lang]).to eql(["is invalid"])
      end

      it "is invalid if lang contains more than 2 characters" do
        document = described_class.new :lang => "abc", :type => "add"
        document.valid?
        expect(document.errors[:lang]).to eql(["is invalid"])
      end

      it "is invalid if lang contains upper case characters" do
        document = described_class.new :lang => "Ab", :type => "add"
        document.valid?
        expect(document.errors[:lang]).to eql(["is invalid"])
      end

      it "is valid if lang contains 2 lower case characters" do
        document = described_class.new :lang => "en", :type => "add"
        document.valid?
        expect(document.errors[:lang]).to be_nil
      end
    end

    context "when type is 'delete'" do
      it "is optional" do
        document = described_class.new :type => "delete"
        document.valid?
        expect(document.errors[:lang]).to be_nil
      end
    end
  end

  context "fields validation" do
    context "when type is 'add'" do
      it "is invalid if fields is nil" do
        document = described_class.new :fields => nil, :type => "add"
        document.valid?
        expect(document.errors[:fields]).to eql(["can't be empty"])
      end

      it "is invalid if fields is not a hash" do
        document = described_class.new :fields => [], :type => "add"
        document.valid?
        expect(document.errors[:fields]).to eql(["must be an instance of Hash"])
      end

      it "is valid with a Hash" do
        document = described_class.new :fields => {}, :type => "add"
        document.valid?
        expect(document.errors[:fields]).to be_nil
      end
    end

    context "when type is 'delete'" do
      it "is optional" do
        document = described_class.new :type => "delete"
        document.valid?
        expect(document.errors[:fields]).to be_nil
      end
    end
  end

  context "#as_json" do
    let(:attributes) { {
      :type    => type,
      :id      => "123abc",
      :version => 123456,
      :lang    => "pt",
      :fields  => {:foo => "bar"}
    } }
    let(:document) { described_class.new attributes }
    let(:as_json) { document.as_json }

    context "when 'type' is 'add'" do
      let(:type) { "add" }

      it "includes the 'type' attribute" do
        expect(as_json[:type]).to eq("add")
      end

      it "includes the 'id' attribute" do
        expect(as_json[:id]).to eq("123abc")
      end

      it "includes the 'version' attribute" do
        expect(as_json[:version]).to eq(123456)
      end

      it "includes the 'lang' attribute" do
        expect(as_json[:lang]).to eq("pt")
      end

      it "includes the 'fields' attribute" do
        expect(as_json[:fields]).to eq(:foo => "bar")
      end
    end

    context "when 'type' is 'delete'" do
      let(:type) { "delete" }

      it "includes the 'type' attribute" do
        expect(as_json[:type]).to eq("delete")
      end

      it "includes the 'id' attribute" do
        expect(as_json[:id]).to eq("123abc")
      end

      it "includes the 'version' attribute" do
        expect(as_json[:version]).to eq(123456)
      end

      it "does not include the 'lang' attribute" do
        expect(as_json[:lang]).to be_nil
      end

      it "does not include the 'fields' attribute" do
        expect(as_json[:fields]).to be_nil
      end
    end
  end

  context "#to_json" do
    let(:attributes) { {
      :type    => type,
      :id      => "123abc",
      :version => 123456,
      :lang    => "pt",
      :fields  => {:foo => "bar"}
    } }
    let(:parsed_json) { JSON.parse(described_class.new(attributes).to_json) }

    context "when 'type' is 'add'" do
      let(:type) { "add" }

      it "includes the 'type' attribute" do
        expect(parsed_json["type"]).to eq("add")
      end

      it "includes the 'id' attribute" do
        expect(parsed_json["id"]).to eq("123abc")
      end

      it "includes the 'version' attribute" do
        expect(parsed_json["version"]).to eq(123456)
      end

      it "includes the 'lang' attribute" do
        expect(parsed_json["lang"]).to eq("pt")
      end

      it "includes the 'fields' attribute" do
        expect(parsed_json["fields"]).to eq("foo" => "bar")
      end
    end

    context "when 'type' is 'delete'" do
      let(:type) { "delete" }

      it "includes the 'type' attribute" do
        expect(parsed_json["type"]).to eq("delete")
      end

      it "includes the 'id' attribute" do
        expect(parsed_json["id"]).to eq("123abc")
      end

      it "includes the 'version' attribute" do
        expect(parsed_json["version"]).to eq(123456)
      end

      it "does not include the 'lang' attribute" do
        expect(parsed_json["lang"]).to be_nil
      end

      it "does not include the 'fields' attribute" do
        expect(parsed_json["fields"]).to be_nil
      end
    end
  end
end

