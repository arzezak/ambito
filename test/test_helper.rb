# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ambito"
require "minitest/autorun"
require "webmock/minitest"

module TestHelper
  def fixture(name)
    JSON.parse File.read("./test/fixtures/#{name}.json")
  end

  def stub_ambito_request(dollar, override: {})
    stub_request(:get, /#{String(dollar).squeeze}/).to_return_json(
      body: fixture(dollar).merge(override)
    )
  end
end
