class DocumentClassifier
  class Analyzer
    extend Memoist

    attr_reader :words

    def initialize(words)
      @words = words
    end

    def unigrams
      ngrams(1)
    end

    def bigrams
      ngrams(2)
    end

    def trigrams
      ngrams(3)
    end

    def frequency(word)
      unigrams.fetch([word])
    rescue KeyError
      0
    end

    def word_count
      words.count
    end

    private memoize def ngrams(n)
      words.each_cons(n).reduce(Hash.new(0)) { |hsh, ngram| hsh[ngram] += 1; hsh }
    end
  end
end
