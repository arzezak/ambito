module Ambito
  class Dollar
    TRENDS = {up: "📈", down: "📉", equal: "📊"}.freeze

    def initialize(rate:, buy:, sell:, variation:)
      @rate = rate
      @buy = float(buy)
      @sell = float(sell)
      @variation = float(variation)
    end

    def average
      (buy + sell) / 2
    end

    def to_s
      "#{rate.display}: $ #{format(average)} #{trend} #{format(variation)}%"
    end

    private

    attr_reader :rate, :buy, :sell, :variation

    def trend
      if variation.positive?
        TRENDS[:up]
      elsif variation.negative?
        TRENDS[:down]
      else
        TRENDS[:equal]
      end
    end

    def float(value)
      value.tr(",", ".").to_f
    end

    def format(number)
      sprintf("%.2f" % number)
    end
  end
end
