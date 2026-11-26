# frozen_string_literal: true

require "swarf/probe"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ambito"
require "minitest/autorun"
require "webmock/minitest"

module TestHelper
  def fixture(name)
    JSON.parse File.read("./test/fixtures/#{name}.json")
  end

  def stub_all_ambito_requests
    Ambito::Dollar.all.each { |dollar| stub_ambito_request dollar.name }
  end

  def stub_ambito_request(dollar, override: {})
    stub_request(:get, "#{Ambito::Gateway::BASE_URL}#{Ambito::Dollar.find(dollar).endpoint}").to_return_json(
      body: fixture(dollar).merge(override.transform_keys(&:to_s))
    )
  end

  def stub_ambito_history(dollar, from:, to:, body: fixture("#{dollar}_history"))
    stub_request(
      :get,
      "#{Ambito::Gateway::BASE_URL}#{File.dirname(Ambito::Dollar.find(dollar).endpoint)}/grafico/#{from}/#{to}"
    ).to_return_json(body:)
  end
end
