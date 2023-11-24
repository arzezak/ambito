module Ambito
  class Rate
    TRENDS = {up: "📈", down: "📉", equal: "📊"}.freeze

    def initialize(dollar:, buy:, sell:, value:, variation:)
      @dollar = dollar
      @buy = float(buy)
      @sell = float(sell)
      @value = float(value)
      @variation = float(variation)
    end

    def average
      (buy + sell) / 2
    end

    def to_s
      "#{dollar}: $ #{format(price)} #{trend} #{format(variation)}%"
    end

    private

    attr_reader :dollar, :buy, :sell, :value, :variation

    def float(number)
      number && number.tr(",", ".").to_f || nil
    end

    def format(number)
      sprintf("%.2f" % number)
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
