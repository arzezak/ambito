# frozen_string_literal: true

require "net/http"
require "json"
require "yaml"
require_relative "ambito/cli"
require_relative "ambito/dollar"
require_relative "ambito/rate"
require_relative "ambito/version"

module Ambito
  BASE_URL = "https://mercados.ambito.com"
  DOLLARS = YAML.safe_load_file("./config/dollars.yml", permitted_classes: [Ambito::Dollar])

  class << self
    def run(dollar: nil)
      scope = Array(DOLLARS.detect { _1.name == dollar } || DOLLARS)

      scope.map do |dollar|
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
