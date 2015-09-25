class DocumentClassifier
  class Analyzer
    extend Memoist
    include Normalization

    def initialize(tokens)
      @tokens = tokens
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

    def frequency(token)
      unigrams.fetch([token])
    rescue KeyError
      0
    end

    def token_count
      @tokens.count
    end

    private memoize def ngrams(n)
      token_ngrams(n).reduce(Hash.new(0)) { |hsh, ngram| hsh[ngram] += 1; hsh }
    end

    private def token_ngrams(n)
      normalized_tokens.each_cons(n)
    end

    private def normalized_tokens
      @tokens.map(&method(:normalize))
    end
  end
end
