require "memoist"

require "document_classifier/version"
require "document_classifier/normalization"
require "document_classifier/tokenizer"
require "document_classifier/analyzer"

class DocumentClassifier
  extend Memoist

  attr_reader :categories
  attr_accessor :ignore_words, :stop_words

  def initialize(categories)
    @categories, @ignore_words, @stop_words = categories, [], []

    @frequencies = categories.reduce({}) do |word_frequencies, key|
      word_frequencies[key] = Hash.new(0)
      word_frequencies
    end

    yield(self) if block_given?
  end

  def train(category, text)
    tokenize(text) { |word| @frequencies.fetch(category)[word] += 1 }
    flush_cache(:number_of_words, :number_of_unique_words, :total_number_of_unique_words)
  end

  def classify(text)
    categories.max_by do |category|
      tokenize(text).reduce(0) do |total, word|
        a = frequency(category, word) + smoothing_options.fetch(:k)
        b = number_of_words(category) + smoothing_options.fetch(:k) * vocabulary_size
        total + Math.log2(Rational(a, b).to_f)
      end
    end
  end

  def smoothing_options
    { k: 1 }
  end

  private def frequency(category, word)
    @frequencies.fetch(category)[word]
  end

  private memoize def number_of_words(category)
    @frequencies.fetch(category).values.reduce(:+)
  end

  private memoize def number_of_unique_words(category)
    @frequencies.fetch(category).count
  end

  private memoize def total_number_of_unique_words
    categories.reduce(0) do |count, category|
      count + number_of_unique_words(category)
    end
  end

  alias_method :vocabulary_size, :total_number_of_unique_words

  private def tokenize(text, &block)
    tokenizer(text).each_word(&block)
  end

  private def tokenizer(text)
    Tokenizer.new(text) do |config|
      config.ignore_words = ignore_words
      config.stop_words = stop_words
    end
  end
end
