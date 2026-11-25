module Ambito
  class Table
    TITLES = ["", "Compra", "Venta", "Cambio", "Actualización"].freeze
    STYLES = {dim: 2, red: 31, green: 32, yellow: 33, cyan: 36}.freeze
    GAP_WIDTH = 3

    BETWEEN_BUY_AND_SELL = {
      [true, true] => "┼",
      [true, false] => "┴",
      [false, true] => "┬",
      [false, false] => "─"
    }.freeze

    def initialize(rates, now: Time.now, color: false)
      @rates = rates
      @now = now
      @color = color
    end

    def to_s
      [
        rule("┌", "┬", "┐", [false, true]),
        *lines.zip(dividers).flatten.compact,
        rule("└", "┴", "┘", [splits.last, false])
      ].join("\n")
    end

    private

    attr_reader :rates, :now, :color

    def lines
      [heading, *rates.map { |rate| quote(rate) }]
    end

    def dividers
      splits.each_cons(2).map { |neighbors| rule("├", "┼", "┤", neighbors) }
    end

    def splits
      [true, *rates.map { |rate| rate.value.nil? }]
    end

    def heading
      frame(TITLES.each_with_index.map { |title, column| paint(fit(title, column), :yellow) })
    end

    def quote(rate)
      frame(
        [
          paint(fit(rate.dollar.to_s, 0), :cyan),
          *prices(rate),
          paint(fit(rate.variation.to_s, 3), trend(rate)),
          fit(age(rate), 4)
        ]
      )
    end

    def prices(rate)
      return [paint(rate.value.to_s.center(widths[1] + GAP_WIDTH + widths[2]), :cyan)] if rate.value

      [paint(fit(rate.buy.to_s, 1), :cyan), paint(fit(rate.sell.to_s, 2), :cyan)]
    end

    def trend(rate)
      rate.variation.value.negative? ? :red : :green
    end

    def age(rate)
      rate.updated_at ? "hace #{Age.new(now - rate.updated_at)}" : ""
    end

    def frame(cells)
      bar = paint("│", :dim)

      "#{bar} #{cells.join(" #{bar} ")} #{bar}"
    end

    def rule(left, junction, right, neighbors)
      name, buy, sell, *others = widths.map { |width| "─" * (width + 2) }

      paint(
        [left, name, junction, buy, BETWEEN_BUY_AND_SELL[neighbors], sell, junction, others.join(junction), right].join,
        :dim
      )
    end

    def fit(cell, column)
      cell.ljust(widths[column])
    end

    def paint(text, style)
      color ? "\e[#{STYLES[style]}m#{text}\e[0m" : text
    end

    def widths
      @widths ||= [TITLES, *rates.map { |rate| cells(rate) }].transpose.map do |cells_in_column|
        cells_in_column.map(&:length).max
      end
    end

    def cells(rate)
      [rate.dollar.to_s, *sides(rate), rate.variation.to_s, age(rate)]
    end

    def sides(rate)
      rate.value ? ["", ""] : [rate.buy.to_s, rate.sell.to_s]
    end
  end
end
