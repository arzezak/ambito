# frozen_string_literal: true

require "net/http"
require "json"

module Ambito
  class Gateway
    BASE_URL = "https://mercados.ambito.com"

    def initialize(endpoint:)
      @endpoint = endpoint
    end

    def get(*)
      JSON.parse(request).values_at(*)
    end

    private

    attr_reader :endpoint

    def request
      Net::HTTP.get(uri)
    end

    def uri
      URI.join(BASE_URL, endpoint)
    end
  end
end
