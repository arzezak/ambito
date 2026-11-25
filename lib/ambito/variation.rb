module Ambito
  class Variation
    attr_reader :value

    def initialize(value)
      @value = value
    end

    def to_s
      "#{"+" if value.positive?}%.2f%%" % value
    end
  end
end
