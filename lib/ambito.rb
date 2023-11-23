# frozen_string_literal: true

require "net/http"
require "json"
require_relative "ambito/cli"
require_relative "ambito/dollar"
require_relative "ambito/rate"
require_relative "ambito/version"

module Ambito
  BASE_URL = "https://mercados.ambito.com"

  class << self
    def run(dollar: nil)
      Array(Dollar.where(name: dollar)).map do |dollar|
        res = JSON.parse(Net::HTTP.get(uri(dollar.endpoint)))
        buy, sell, variation = res.values_at("compra", "venta", "variacion")
        Rate.new(dollar:, buy:, sell:, variation:)
      end
    end

    private

    def uri(endpoint)
      URI.join(BASE_URL, endpoint)
    end
  end
end
