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
  end
end
