module Ambito
  module Paint
    STYLES = {dim: 2, red: 31, green: 32, yellow: 33, cyan: 36}.freeze

    private

    def paint(text, style)
      color ? "\e[#{STYLES[style]}m#{text}\e[0m" : text
    end
  end
end
