module Ambito
  class Price
    attr_reader :quote

    def initialize(quote)
      @quote = parse(quote)
    end

    def +(other)
      self.class.new(quote + other.quote)
    end

    def /(other)
      self.class.new(quote / other)
    end

    def parse(quote)
      String(quote).tr(",", ".").to_f
    end

    def to_s
      sprintf("$ %.2f" % quote)
    end

    class << self
      def [](quote)
        quote && new(quote) || nil
      end
    end
  end
end
