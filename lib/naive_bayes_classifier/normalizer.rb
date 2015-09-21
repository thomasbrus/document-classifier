module NaiveBayesClassifier
  module Normalizer
    def normalize(tokens)
      tokens.map(&:downcase)
    end
  end
end
