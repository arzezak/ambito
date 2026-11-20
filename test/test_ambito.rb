# frozen_string_literal: true

require "test_helper"

class TestAmbito < Minitest::Test
  include TestHelper

  def test_that_it_has_a_version_number
    refute_nil ::Ambito::VERSION
  end

  def test_that_it_returns_a_formatted_string
    stub_all_ambito_requests

    assert_equal <<~OUTPUT.chomp, Ambito.rates.join("\n")
      CCL: $ 858.28 📉 -7.10%
      Cripto: $ 980.98 📈 0.01%
      Informal: $ 970.00 📉 -4.78%
      MEP: $ 972.75 📉 -3.30%
      Oficial: $ 365.38 📈 0.23%
      Turista: $ 960.56 📈 0.35%
    OUTPUT
  end

  def test_that_it_exposes_the_values_of_a_rate
    stub_ambito_request :oficial

    rate = Ambito.rate(:oficial)

    assert_equal "oficial", rate.dollar.name
    assert_in_delta 355.38, rate.buy.quote
    assert_in_delta 375.38, rate.sell.quote
    assert_in_delta 365.38, rate.price.quote
    assert_in_delta 0.23, rate.variation.value
  end

  def test_that_it_includes_emoji_reflecting_upward_trends
    stub_ambito_request :oficial, override: {variacion: "0,23%"}

    assert_equal "📈", Ambito.rate(:oficial).variation.trend
  end

  def test_that_it_includes_emoji_reflecting_downward_trends
    stub_ambito_request :oficial, override: {variacion: "-0,23%"}

    assert_equal "📉", Ambito.rate(:oficial).variation.trend
  end

  def test_that_it_includes_emoji_reflecting_stable_trends
    stub_ambito_request :oficial, override: {variacion: "0,00%"}

    assert_equal "📊", Ambito.rate(:oficial).variation.trend
  end

  def test_that_it_uses_value_when_available
    stub_ambito_request :oficial, override: {valor: "462,13"}

    assert_in_delta 462.13, Ambito.rate(:oficial).price.quote
  end

  def test_that_it_fetches_a_custom_dollar
    dollar = Ambito::Dollar.new(
      name: "mayorista",
      display: "Mayorista",
      endpoint: "/dolar/mayorista/variacion"
    )
    stub_request(:get, "https://mercados.ambito.com/dolar/mayorista/variacion")
      .to_return_json(body: fixture(:oficial))

    assert_equal "Mayorista: $ 365.38 📈 0.23%", Ambito::Gateway.new(dollar).rate.to_s
  end

  def test_that_it_raises_on_an_unknown_dollar
    error = assert_raises(Ambito::Error) { Ambito.rate(:nope) }

    assert_equal "Unknown dollar: nope", error.message
  end

  def test_that_it_raises_on_a_missing_field
    stub_request(:get, /oficial/).to_return_json(body: fixture(:oficial).except("compra"))

    error = assert_raises(Ambito::Error) { Ambito.rate(:oficial) }

    assert_equal "Oficial: bad compra in response", error.message
  end

  def test_that_it_raises_on_a_response_that_is_not_json
    stub_request(:get, /oficial/).to_return(body: "<html></html>")

    assert_raises(Ambito::Error) { Ambito.rate(:oficial) }
  end

  def test_that_it_raises_on_an_http_error
    stub_request(:get, /oficial/).to_return(status: 403, body: "{}")

    error = assert_raises(Ambito::Error) { Ambito.rate(:oficial) }

    assert_equal "Oficial: HTTP 403", error.message
  end

  def test_that_rates_raises_when_one_dollar_fails
    stub_all_ambito_requests
    stub_request(:get, /mep/).to_return(status: 500)

    assert_raises(Ambito::Error) { Ambito.rates }
  end

  def test_that_the_cli_prints_all_rates
    stub_all_ambito_requests

    assert_output(/\ACCL: .+^Turista: \$ 960\.56 📈 0\.35%\n\z/m) { Ambito::CLI.new([]).run }
  end

  def test_that_the_cli_prints_a_single_rate
    stub_ambito_request :oficial

    assert_output("Oficial: $ 365.38 📈 0.23%\n") { Ambito::CLI.new(%w[-d oficial]).run }
  end

  def test_that_the_cli_prints_the_version
    assert_output("#{Ambito::VERSION}\n") { Ambito::CLI.new(%w[-v]).run }
  end

  def test_that_the_cli_exits_with_the_error_message
    _, err = capture_io do
      assert_raises(SystemExit) { Ambito::CLI.new(%w[-d nope]).run }
    end

    assert_equal "Unknown dollar: nope\n", err
  end
end
