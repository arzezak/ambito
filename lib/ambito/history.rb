module Ambito
  class History
    Point = Data.define(:date, :price)

    attr_reader :dollar, :points

    def initialize(dollar:, quotes:)
      @dollar = dollar
      @points = quotes.sort.map { |date, quote| Point.new(date:, price: Price.new(quote)) }
    end

    def opening
      points.first
    end

    def closing
      points.last
    end

    def high
      points.max_by { |point| point.price.quote }
    end

    def low
      points.min_by { |point| point.price.quote }
    end

    def change
      closing.price.quote - opening.price.quote
    end

    def variation
      Variation.new(change / opening.price.quote * 100)
    end
  end
end
