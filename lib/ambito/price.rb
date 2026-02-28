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

    def to_s
      "$ %.2f" % quote
    end

    private

    def parse(quote)
      String(quote).tr(",", ".").to_f
    end
  end
end
