module Ambito
  class Rate
    attr_reader :dollar, :buy, :sell, :variation

    def initialize(dollar:, buy:, sell:, variation:, value: nil)
      @dollar = dollar
      @buy = Price.new(buy)
      @sell = Price.new(sell)
      @value = value && Price.new(value)
      @variation = Variation.new(variation)
    end

    def price
      value || average
    end

    def average
      (buy + sell) / 2
    end

    def to_s
      "#{dollar}: #{price} #{variation.trend} #{variation}"
    end

    private

    attr_reader :value
  end
end
