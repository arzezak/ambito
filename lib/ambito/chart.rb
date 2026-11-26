require_relative "paint"

module Ambito
  class Chart
    include Paint

    BLANK_BRAILLE = 0x2800
    DOTS_PER_CELL_ROW = 4
    DOTS_PER_CELL_COLUMN = 2

    DOT_BITS = [
      [0x01, 0x08],
      [0x02, 0x10],
      [0x04, 0x20],
      [0x40, 0x80]
    ].freeze

    def initialize(history, width: 72, height: 16, color: false)
      @history = history
      @width = width
      @height = height
      @color = color
    end

    def to_s
      [heading, "", *plot, "", *summary].join("\n")
    end

    private

    attr_reader :history, :width, :height, :color

    def heading
      "#{paint(history.dollar, :cyan)}  #{day(history.opening, "%d/%m/%Y")} – #{day(history.closing, "%d/%m/%Y")}  " \
        "#{paint(history.variation, trend)}"
    end

    def plot
      [
        axis(history.high.price),
        *rows.map { |row| axis(paint(row, :cyan)) },
        axis(history.low.price),
        paint("  └#{"─" * (width + 1)}", :dim)
      ]
    end

    def summary
      separator = paint("//", :dim)

      [
        "#{label("Inicio")} #{stamp(history.opening)}  #{separator}  #{label("Fin")} #{stamp(history.closing)}",
        "#{label("Máximo")} #{stamp(history.high)}  #{separator}  #{label("Mínimo")} #{stamp(history.low)}",
        "#{label("Cambio")} #{paint("%+.2f" % history.change, trend)} (#{paint(history.variation, trend)})"
      ]
    end

    def axis(text)
      "#{paint("  │", :dim)} #{text}".rstrip
    end

    def label(name)
      paint("#{name}:", :dim)
    end

    def stamp(point)
      "#{point.price} (#{day(point, "%d/%m")})"
    end

    def day(point, format)
      point.date.strftime(format)
    end

    def trend
      history.change.negative? ? :red : :green
    end

    def rows
      cells = Array.new(height) { Array.new(width, 0) }

      dots.each do |column, level|
        cells[height - 1 - level / DOTS_PER_CELL_ROW][column / DOTS_PER_CELL_COLUMN] |=
          DOT_BITS[DOTS_PER_CELL_ROW - 1 - level % DOTS_PER_CELL_ROW][column % DOTS_PER_CELL_COLUMN]
      end

      cells.map do |cells_in_row|
        cells_in_row.map { |bits| bits.zero? ? " " : (BLANK_BRAILLE + bits).chr(Encoding::UTF_8) }.join.rstrip
      end
    end

    def dots
      marks.each_cons(2).flat_map do |(from_column, from_level), (to_column, to_level)|
        steps = [to_column - from_column, (to_level - from_level).abs, 1].max

        (0..steps).map do |step|
          [
            from_column + ((to_column - from_column) * step / steps.to_f).round,
            from_level + ((to_level - from_level) * step / steps.to_f).round
          ]
        end
      end
    end

    def marks
      first_day = history.opening.date
      lowest_quote = history.low.price.quote

      history.points.map do |point|
        [
          scale(point.date - first_day, history.closing.date - first_day, width * DOTS_PER_CELL_COLUMN),
          scale(point.price.quote - lowest_quote, history.high.price.quote - lowest_quote, height * DOTS_PER_CELL_ROW)
        ]
      end
    end

    def scale(offset, extent, dot_count)
      extent.zero? ? 0 : (offset * (dot_count - 1) / extent.to_f).round
    end
  end
end
