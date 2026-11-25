module Ambito
  class Age
    UNITS = {"d" => 86_400, "h" => 3_600, "min" => 60}.freeze

    def initialize(seconds)
      @seconds = seconds.clamp(0..)
    end

    def to_s
      "#{(seconds / UNITS[unit]).floor} #{unit}"
    end

    private

    attr_reader :seconds

    def unit
      UNITS.keys.find { |name| seconds >= UNITS[name] } || UNITS.keys.last
    end
  end
end
