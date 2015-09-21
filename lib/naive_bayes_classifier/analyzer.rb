module NaiveBayesClassifier
  class Analyzer
    include Tokenizer
    include Normalizer

    def initialize(corpus)
      @tokens = tokenize(corpus)
    end

    def ngrams(n)
      token_ngrams(n).reduce(Hash.new(0)) do |hsh, ngram|
        hsh[ngram] += 1
        hsh
      end
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

    private def token_ngrams(n)
      normalized_tokens.each_cons(n)
    end

    private def normalized_tokens
      normalize(@tokens)
    end
  end
end
