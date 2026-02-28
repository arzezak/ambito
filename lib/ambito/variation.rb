module Ambito
  class Variation
    TRENDS = {up: "📈", down: "📉", equal: "📊"}.freeze

    attr_reader :value

    def initialize(value)
      @value = parse(value)
    end

    def to_s
      "%.2f%%" % value
    end

    def trend
      if value.positive?
        TRENDS[:up]
      elsif value.negative?
        TRENDS[:down]
      else
        TRENDS[:equal]
      end
    end

    private

    def parse(value)
      value.tr(",", ".").to_f
    end

    class << self
      def [](value)
        new(value)
      end
    end
  end
end
