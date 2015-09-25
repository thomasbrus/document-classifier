class DocumentClassifier
  module Normalization
    def normalize(token)
      token.downcase.strip
    end
  end
end
