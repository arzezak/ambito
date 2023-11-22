module Ambito
  class Dollar
    TRENDS = {up: "📈", down: "📉", equal: "📊"}.freeze
    TYPES = {oficial: "Oficial", informal: "Informal", mep: "MEP"}.freeze

    def initialize(buy:, sell:, type:, variation:)
      @buy = float(buy)
      @sell = float(sell)
      @type = TYPES.fetch(type.to_sym)
      @variation = float(variation)
    end

    def average
      (buy + sell) / 2
    end

    def to_s
      "#{type}: $ #{format(average)} #{emoji} #{format(variation)}%"
    end

    private

    attr_reader :buy, :sell, :type, :variation

    def emoji
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
