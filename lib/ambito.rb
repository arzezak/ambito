# frozen_string_literal: true

require "net/http"
require "json"
require "yaml"
require_relative "ambito/cli"
require_relative "ambito/dollar"
require_relative "ambito/rate"
require_relative "ambito/version"

module Ambito
  class Error < StandardError; end

  BASE_URL = "https://mercados.ambito.com"
  RATES = YAML.safe_load_file("./config/rates.yml", permitted_classes: [Ambito::Rate])

  class << self
    def run(rate: nil)
      scope = Array(RATES.detect { _1.name == rate } || RATES)

      scope.map do |rate|
        res = JSON.parse(Net::HTTP.get(uri(rate.endpoint)))
        buy, sell, variation = res.values_at("compra", "venta", "variacion")
        Dollar.new(rate: rate, buy:, sell:, variation:)
      end
    end

    private

    def uri(endpoint)
      URI.join(BASE_URL, endpoint)
    end
  end
end
