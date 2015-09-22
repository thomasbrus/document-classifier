module NaiveBayesClassifier
  class Analyzer
    include Tokenizer
    include Normalizer

    def initialize(corpus, vocabulary: nil)
      @tokens = tokenize(corpus).select do |token|
        vocabulary.nil? || vocabulary.include?(normalize(token))
      end
    end

    def ngrams(n)
      token_ngrams(n).reduce(Hash.new(0)) { |hsh, ngram| hsh[ngram] += 1; hsh }
    end

    def unigrams
      @unigrams ||= ngrams(1)
    end

    def bigrams
      @bigrams ||= ngrams(2)
    end

    def trigrams
      @trigrams ||= ngrams(3)
    end

    def frequency_of(word)
      unigrams.fetch([normalize(word)])
    end

    def word_count
      @tokens.count
    end

    private def token_ngrams(n)
      normalized_tokens.each_cons(n)
    end

    private def normalized_tokens
      @tokens.map(&method(:normalize))
    end
  end
end
