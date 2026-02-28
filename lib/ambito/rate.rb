module Ambito
  class Rate
    def initialize(dollar:, buy:, sell:, value:, variation:)
      @dollar = dollar
      @buy = Price[buy]
      @sell = Price[sell]
      @value = Price[value]
      @variation = Variation[variation]
    end

    def average
      Price[(buy + sell) / 2]
    end

    def to_s
      "#{dollar}: #{price} #{variation.trend} #{variation}"
    end

    private

    attr_reader :dollar, :buy, :sell, :value, :variation

    def price
      value || average
    end
  end
end
