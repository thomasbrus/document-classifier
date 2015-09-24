class DocumentClassifier
  class Document
    include Tokenizer
    include Normalizer

    attr_reader :words

    def initialize(content)
      @words = tokenize(content).map(&method(:normalize))
    end

    def self.from_file(filename)
      new(File.read(filename))
    end

    def each_word(&block)
      @words.each(&block)
    end
  end
end
