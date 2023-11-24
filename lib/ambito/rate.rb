module Ambito
  class Rate
    TRENDS = {up: "📈", down: "📉", equal: "📊"}.freeze

    def initialize(dollar:, buy:, sell:, value:, variation:)
      @dollar = dollar
      @buy = Price[buy]
      @sell = Price[sell]
      @value = Price[value]
      @variation = variation.tr(",", ".").to_f
    end

    def average
      Price[(buy + sell) / 2]
    end

    def to_s
      "#{dollar}: #{price} #{trend} #{formatted_variation}%"
    end

    private

    attr_reader :dollar, :buy, :sell, :value, :variation

    def formatted_variation
      sprintf("%.2f" % variation)
    end

    def price
      value || average
    end

    def trend
      if variation.positive?
        TRENDS[:up]
      elsif variation.negative?
        TRENDS[:down]
      else
        TRENDS[:equal]
      end
    end
  end
end
