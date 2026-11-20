# frozen_string_literal: true

require "net/http"
require "json"

module Ambito
  class Gateway
    BASE_URL = "https://mercados.ambito.com"

    def initialize(dollar)
      @dollar = dollar
    end

    def rate
      Rate.new(
        dollar:,
        buy: number("compra"),
        sell: number("venta"),
        value: (number("valor") if payload.key?("valor")),
        variation: number("variacion")
      )
    end

    private

    attr_reader :dollar

    def number(field)
      parse(payload[field]) || raise(Error, "#{dollar}: bad #{field} in response")
    end

    def parse(text)
      Float(String(text).tr(",", ".").delete_suffix("%"), exception: false)
    end

    def payload
      @payload ||= Hash.try_convert(json) || raise(Error, "#{dollar}: unexpected response")
    end

    def json
      JSON.parse(body)
    rescue JSON::ParserError
      nil
    end

    def body
      raise Error, "#{dollar}: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

      response.body
    end

    def response
      @response ||= Net::HTTP.get_response(URI.join(BASE_URL, dollar.endpoint))
    end
  end
end
