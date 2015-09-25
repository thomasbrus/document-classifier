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
    @categories, @word_frequencies = categories, categories.reduce({}) do |hsh, key|
      hsh[key] = Hash.new(0)
      hsh
    end

    yield(self) if block_given?
  end

  def train(category, text)
    tokenize(text) { |word| @word_frequencies.fetch(category)[word] += 1 }
    flush_cache(:total_number_of_words, :number_of_words)
  end

  def classify(text)
    categories.max_by do |category|
      tokenize(text).reduce(0) do |total, word|
        a = frequency(category, word) + smoothing_options.fetch(:k)
        b = number_of_words(category) + smoothing_options.fetch(:k) * total_number_of_words
        total + Math.log2(Rational(a, b).to_f)
      end
    end
  end

  def smoothing_options
    { k: 1 }
  end

  private def frequency(category, word)
    @word_frequencies.fetch(category)[word]
  end

  private memoize def total_number_of_words
    categories.reduce(0) { |count, category| count + number_of_words(category) }
  end

  private memoize def number_of_words(category)
    @word_frequencies.fetch(category).values.reduce(:+)
  end

  private def tokenize(text, &block)
    tokenizer = Tokenizer.new(text) do |tokenizer_config|
      # tokenizer_config.ignore_words = ignore_words unless ignore_words.nil?
      # tokenizer_config.stop_words = stop_words unless ignore_words.nil?
    end

    tokenizer.each_word(&block)
  end
end
