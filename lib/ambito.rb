# frozen_string_literal: true

require "net/http"
require "json"
require_relative "ambito/cli"
require_relative "ambito/dollar"
require_relative "ambito/version"

module Ambito
  class Error < StandardError; end

  DOLLARS = %w[
    dolar/oficial
    dolar/informal
    dolarrava/mep
  ].freeze

  class << self
    def run
      DOLLARS.map do |dollar|
        res = JSON.parse(Net::HTTP.get(uri(dollar)))
        type = dollar.split("/").last
        buy, sell, variation = res.values_at("compra", "venta", "variacion")
        Dollar.new(type:, buy:, sell:, variation:)
      end
    end

    DOLLARS.each do |dollar|
      type = dollar.split("/").last

      define_method(type) do
        res = JSON.parse(Net::HTTP.get(uri(dollar)))
        type = dollar.split("/").last
        buy, sell, variation = res.values_at("compra", "venta", "variacion")
        Dollar.new(type:, buy:, sell:, variation:)
      end
    end

    private

    def uri(dollar)
      URI("https://mercados.ambito.com/#{dollar}/variacion")
    end
  end
end
