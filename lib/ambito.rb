# frozen_string_literal: true

require_relative "ambito/cli"
require_relative "ambito/dollar"
require_relative "ambito/gateway"
require_relative "ambito/rate"
require_relative "ambito/version"

module Ambito
  class << self
    def run(dollar: nil)
      Array(Dollar.where(name: dollar)).map do |dollar|
        gateway = Gateway.new(endpoint: dollar.endpoint)
        buy, sell, variation = gateway.get("compra", "venta", "variacion")

        Rate.new(dollar:, buy:, sell:, variation:)
      end
    end
  end
end
