module CloudSearch
  class Indexer
    def initialize
      @documents = []
    end

    def <<(document)
      raise InvalidDocument.new(document) unless document.valid?
      @documents << document
    end

    alias :add :<<

    def documents
      @documents.freeze
    end
  end
end
