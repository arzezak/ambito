# frozen_string_literal: true

require "test_helper"

class TestAmbito < Minitest::Test
  include TestHelper

  NOW = Time.new(2026, 11, 25, 15, 42, 0, "-03:00")

  def test_that_it_has_a_version_number
    refute_nil ::Ambito::VERSION
  end

  def test_that_it_returns_a_rate_for_every_dollar
    stub_all_ambito_requests

    assert_equal %w[bna ccl cripto informal mep oficial turista], Ambito.rates.map { |rate| rate.dollar.name }
  end

  def test_that_it_exposes_the_values_of_a_rate
    stub_ambito_request :oficial

    rate = Ambito.rate(:oficial)

    assert_equal "oficial", rate.dollar.name
    assert_in_delta 355.38, rate.buy.quote
    assert_in_delta 375.38, rate.sell.quote
    assert_in_delta 0.23, rate.variation.value
  end

  def test_that_it_reads_when_the_rate_was_updated
    stub_ambito_request :bna

    assert_equal Time.new(2026, 11, 25, 15, 30, 0, "-03:00"), Ambito.rate(:bna).updated_at
  end

  def test_that_it_has_no_update_time_when_the_date_is_unreadable
    stub_ambito_request :bna, override: {fecha: "N/D"}

    assert_nil Ambito.rate(:bna).updated_at
  end

  def test_that_it_reads_the_published_value
    stub_ambito_request :oficial, override: {valor: "462,13"}

    assert_in_delta 462.13, Ambito.rate(:oficial).value.quote
  end

  def test_that_it_fetches_a_custom_dollar
    dollar = Ambito::Dollar.new(
      name: "mayorista",
      display: "Mayorista",
      endpoint: "/dolar/mayorista/variacion"
    )
    stub_request(:get, "https://mercados.ambito.com/dolar/mayorista/variacion")
      .to_return_json(body: fixture(:oficial))

    rate = Ambito::Gateway.new(dollar).rate

    assert_equal "Mayorista", rate.dollar.to_s
    assert_in_delta 375.38, rate.sell.quote
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

  def test_that_it_raises_on_a_field_that_is_not_a_number
    stub_ambito_request :oficial, override: {compra: "N/D"}

    error = assert_raises(Ambito::Error) { Ambito.rate(:oficial) }

    assert_equal "Oficial: bad compra in response", error.message
  end

  def test_that_it_raises_on_json_that_is_not_an_object
    stub_request(:get, /oficial/).to_return_json(body: [])

    error = assert_raises(Ambito::Error) { Ambito.rate(:oficial) }

    assert_equal "Oficial: unexpected response", error.message
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

    assert_output(<<~OUTPUT) { Ambito::CLI.new([], now: NOW).run }
      ┌──────────┬───────────┬───────────┬────────┬───────────────┐
      │          │ Compra    │ Venta     │ Cambio │ Actualización │
      ├──────────┼───────────┼───────────┼────────┼───────────────┤
      │ BNA      │ $ 1580.00 │ $ 1630.00 │ +0.93% │ hace 12 min   │
      ├──────────┼───────────┴───────────┼────────┼───────────────┤
      │ CCL      │       $ 858.28        │ -7.10% │               │
      ├──────────┼───────────────────────┼────────┼───────────────┤
      │ Cripto   │       $ 980.98        │ +0.01% │               │
      ├──────────┼───────────┬───────────┼────────┼───────────────┤
      │ Informal │ $ 945.00  │ $ 995.00  │ -4.78% │               │
      ├──────────┼───────────┴───────────┼────────┼───────────────┤
      │ MEP      │       $ 972.75        │ -3.30% │               │
      ├──────────┼───────────┬───────────┼────────┼───────────────┤
      │ Oficial  │ $ 355.38  │ $ 375.38  │ +0.23% │ hace 1 h      │
      ├──────────┼───────────┴───────────┼────────┼───────────────┤
      │ Turista  │       $ 960.56        │ +0.35% │ hace 2 d      │
      └──────────┴───────────────────────┴────────┴───────────────┘
    OUTPUT
  end

  def test_that_the_table_colors_a_falling_rate_red
    stub_ambito_request :informal

    table = Ambito::Table.new([Ambito.rate(:informal)], now: NOW, color: true).to_s

    assert_includes table, "\e[36m$ 945.00\e[0m \e[2m│\e[0m \e[36m$ 995.00\e[0m \e[2m│\e[0m \e[31m-4.78%\e[0m"
  end

  def test_that_the_cli_prints_a_single_rate
    stub_ambito_request :oficial

    assert_output(<<~OUTPUT) { Ambito::CLI.new(%w[-d oficial], now: NOW).run }
      ┌─────────┬──────────┬──────────┬────────┬───────────────┐
      │         │ Compra   │ Venta    │ Cambio │ Actualización │
      ├─────────┼──────────┼──────────┼────────┼───────────────┤
      │ Oficial │ $ 355.38 │ $ 375.38 │ +0.23% │ hace 1 h      │
      └─────────┴──────────┴──────────┴────────┴───────────────┘
    OUTPUT
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
