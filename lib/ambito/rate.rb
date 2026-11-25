module Ambito
  class Rate
    attr_reader :dollar, :buy, :sell, :value, :variation, :updated_at

    def initialize(dollar:, buy:, sell:, variation:, value: nil, updated_at: nil)
      @dollar = dollar
      @buy = Price.new(buy)
      @sell = Price.new(sell)
      @value = value && Price.new(value)
      @variation = Variation.new(variation)
      @updated_at = updated_at
    end

    def price
      value || average
    end

    def average
      (buy + sell) / 2
    end

    def to_s
      ["#{dollar} #{variation.trend} #{variation}", *quotes].join("\n")
    end

    private

    def quotes
      return ["  #{value}"] if value

      ["  Compra  #{buy}", "  Venta   #{sell}"]
    end
  end
end
