module Ambito
  class Price
    attr_reader :quote

    def initialize(quote)
      @quote = quote
    end

    def +(other)
      self.class.new(quote + other.quote)
    end

    def /(other)
      self.class.new(quote / other)
    end

    def to_s
      "$ %.2f" % quote
    end
  end
end
