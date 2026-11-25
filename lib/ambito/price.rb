module Ambito
  class Price
    attr_reader :quote

    def initialize(quote)
      @quote = quote
    end

    def to_s
      "$ %.2f" % quote
    end
  end
end
