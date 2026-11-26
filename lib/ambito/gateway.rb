# frozen_string_literal: true

require "date"
require "net/http"
require "json"
require "time"

module Ambito
  class Gateway
    BASE_URL = "https://mercados.ambito.com"
    TIME_FORMAT = "%d/%m/%Y %H:%M %z"
    DATE_FORMAT = "%d/%m/%Y"
    UTC_OFFSET = "-03:00"

    def initialize(dollar)
      @dollar = dollar
    end

    def rate
      Rate.new(
        dollar:,
        buy: number("compra"),
        sell: number("venta"),
        value: (number("valor") if payload.key?("valor")),
        variation: number("variacion"),
        updated_at:
      )
    end

    def history(from:, to:)
      _titles, *rows = Array.try_convert(fetch("#{File.dirname(dollar.endpoint)}/grafico/#{from}/#{to}")) ||
        raise(Error, "#{dollar}: unexpected response")

      raise Error, "#{dollar}: no history in response" if rows.empty?

      History.new(dollar:, quotes: rows.to_h { |date, quote| [Date.strptime(date, DATE_FORMAT), Float(quote)] })
    rescue ArgumentError, TypeError
      raise Error, "#{dollar}: bad history in response"
    end

    private

    attr_reader :dollar

    def updated_at
      Time.strptime("#{String(payload["fecha"]).delete("-")} #{UTC_OFFSET}", TIME_FORMAT)
    rescue ArgumentError
      nil
    end

    def number(field)
      parse(payload[field]) || raise(Error, "#{dollar}: bad #{field} in response")
    end

    def parse(text)
      Float(String(text).tr(",", ".").delete_suffix("%"), exception: false)
    end

    def payload
      @payload ||= Hash.try_convert(fetch(dollar.endpoint)) || raise(Error, "#{dollar}: unexpected response")
    end

    def fetch(path)
      response = Net::HTTP.get_response(URI.join(BASE_URL, path))
      raise Error, "#{dollar}: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    rescue JSON::ParserError
      nil
    end
  end
end
