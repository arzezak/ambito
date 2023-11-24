# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ambito"
require "minitest/autorun"
require "webmock/minitest"

module TestHelper
  def fixture(name)
    JSON.parse File.read("./test/fixtures/#{name}.json")
  end

  def stub_ambito_request(to:, with:, override: {})
    stub_request(:get, url(to)).to_return_json(body: with.merge(override))
  end

  def url(dolar)
    "https://mercados.ambito.com/#{dolar}/variacion"
  end
end
