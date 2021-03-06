class DocumentClassifier
  class Tokenizer
    extend Memoist
    include Normalization

    @@regexps = {
      # Uniform Quotes
      /''|``|“|”/ => '"',

      # Separate punctuation (except for periods) from words.
      /(^|[[:space:]])(')/u => '\1\2',
      /(?=[\("`{\[:;&#*@~])(.)/ => '\1 ',

      /(.)(?=[?!\)";}\]*:@'~])|(?=[\)}\]])(.)|(.)(?=[({\[])|((^|[[:space:]])-)(?=[^-])/u => '\1 ',

      # Treat double-hyphen as a single token.
      /([^-])(--+)([^-])/ => '\1 \2 \3',
      /([[:space:]]|^)(,)(?=(^[[:space:]]))/u => '\1\2 ',

      # Only separate a comma if a space follows.
      /(.)(,)([[:space:]]|$)/u => '\1 \2\3',

      # Combine dots separated by whitespace to be a single token.
      /\.[[:space:]]\.[[:space:]]\./u => '...',

      # Separate "No.6"
      /(^[[:upper:]]^[[:lower:]]\.)(\d+)/ => '\1 \2',

      # Separate words from ellipses
      /([^\.]|^)(\.{2,})(.?)/ => '\1 \2 \3',
      /(^|[[:space:]])(\.{2,})([^\.[:space:]])/u => '\1\2 \3',
      /(^|[[:space:]])(\.{2,})([^\.[:space:]])/u => '\1 \2\3',

      # Fix %, $,£
      /(\d)%/ => '\1 %',
      /\$(\.?\d)/ => '$ \1',
      /£(\.?\d)/ => '£ \1',

      # Throw away any punctation and weird characters used
      /([{^&*{}()\/\\=!@#$+|;:",.<>?~—□□¤™•·–]|\s[-\_]|[-\_]\s)/ => '',
    }

    attr_reader :text
    attr_accessor :ignore_words, :stop_words

    def initialize(text, &block)
      @text, @ignore_words, @stop_words = text, [], []
      yield(self) if block_given?
    end

    def words
      normalized_tokens - ignore_words - stop_words
    end

    def word_count
      words.count
    end

    def each_word(&block)
      return to_enum(:each_word) unless block_given?
      words.each(&block)
    end

    private memoize def normalized_tokens
      @@regexps.reduce(@text) { |str, (pattern, replacement)|
        normalize(str.gsub(pattern, replacement))
      }.split
    end
  end
end
