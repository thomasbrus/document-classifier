require "document_classifier/version"
require "document_classifier/normalizer"
require "document_classifier/tokenizer"
require "document_classifier/vocabulary"
require "document_classifier/document"
require "document_classifier/analyzer"

class DocumentClassifier
  attr_reader :categories, :vocabulary

  def initialize(categories, vocabulary)
    @categories, @vocabulary = categories, vocabulary

    @word_frequencies = categories.reduce({}) do |hsh, key|
      hsh[key] = Hash.new(0)
      hsh
    end
  end

  def train(category, text)
    Document.new(text).each_word do |word|
      @word_frequencies.fetch(category)[word] += 1 if vocabulary.include?(word)
    end
  end

  def total_number_of_words
    categories.reduce(0) { |count, category| count + number_of_words(category) }
  end

  def number_of_words(category)
    @word_frequencies.fetch(category).values.reduce(:+)
  end

  def frequency(category, word)
    @word_frequencies.fetch(category)[word]
  end

  def classify(text)
    v = total_number_of_words

    categories.max_by do |category|
      c = number_of_words(category)

      Document.new(text).words.reduce(0) do |total, word|
        a = frequency(category, word) + smoothing_options.fetch(:k)
        b = c + smoothing_options.fetch(:k) * v
        total + Math.log2(Rational(a, b).to_f)
      end
    end
  end

  def smoothing_options
    { k: 1 }
  end
end
