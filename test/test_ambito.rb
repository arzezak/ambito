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

  def test_that_it_reads_the_history_of_a_dollar
    stub_ambito_history :bna, from: "2026-10-27", to: "2026-11-26"

    history = Ambito.history(:bna, from: Date.new(2026, 10, 27), to: Date.new(2026, 11, 26))

    assert_equal "bna", history.dollar.name
    assert_equal Date.new(2026, 10, 27), history.opening.date
    assert_in_delta 1565.0, history.opening.price.quote
    assert_equal Date.new(2026, 11, 26), history.closing.date
    assert_in_delta 1625.0, history.closing.price.quote
    assert_equal Date.new(2026, 11, 25), history.high.date
    assert_equal Date.new(2026, 10, 27), history.low.date
    assert_in_delta 60.0, history.change
    assert_in_delta 3.83, history.variation.value, 0.01
  end

  def test_that_the_history_keeps_the_last_quote_of_a_repeated_day
    stub_ambito_history :bna, from: "2026-10-27", to: "2026-11-26"

    history = Ambito.history(:bna, from: Date.new(2026, 10, 27), to: Date.new(2026, 11, 26))

    assert_equal 6, history.points.size
    assert_in_delta 1600.0, history.points[3].price.quote
  end

  def test_that_the_history_raises_on_json_that_is_not_a_list
    stub_ambito_history :bna, from: "2026-10-27", to: "2026-11-26", body: {}

    error = assert_raises(Ambito::Error) do
      Ambito.history(:bna, from: Date.new(2026, 10, 27), to: Date.new(2026, 11, 26))
    end

    assert_equal "BNA: unexpected response", error.message
  end

  def test_that_the_history_raises_on_a_quote_that_is_not_a_number
    stub_ambito_history :bna, from: "2026-10-27", to: "2026-11-26", body: [%w[fecha BNA], ["27/10/2026", "N/D"]]

    error = assert_raises(Ambito::Error) do
      Ambito.history(:bna, from: Date.new(2026, 10, 27), to: Date.new(2026, 11, 26))
    end

    assert_equal "BNA: bad history in response", error.message
  end

  def test_that_the_history_raises_when_it_has_no_quotes
    stub_ambito_history :bna, from: "2026-10-27", to: "2026-11-26", body: [%w[fecha BNA]]

    error = assert_raises(Ambito::Error) do
      Ambito.history(:bna, from: Date.new(2026, 10, 27), to: Date.new(2026, 11, 26))
    end

    assert_equal "BNA: no history in response", error.message
  end

  def test_that_the_chart_draws_the_history
    history = Ambito::History.new(
      dollar: Ambito::Dollar.find(:bna),
      quotes: {Date.new(2026, 11, 1) => 100.0, Date.new(2026, 11, 8) => 107.0}
    )

    chart = Ambito::Chart.new(history, width: 4, height: 2).to_s

    assert_equal <<~CHART.chomp, chart
      BNA  01/11/2026 – 08/11/2026  +7.00%

        │ $ 107.00
        │   ⡠⠊
        │ ⡠⠊
        │ $ 100.00
        └─────

      Inicio: $ 100.00 (01/11)  //  Fin: $ 107.00 (08/11)
      Máximo: $ 107.00 (08/11)  //  Mínimo: $ 100.00 (01/11)
      Cambio: +7.00 (+7.00%)
    CHART
  end

  def test_that_the_chart_draws_a_flat_history_on_the_bottom_row
    history = Ambito::History.new(
      dollar: Ambito::Dollar.find(:bna),
      quotes: {Date.new(2026, 11, 1) => 100.0, Date.new(2026, 11, 8) => 100.0}
    )

    chart = Ambito::Chart.new(history, width: 4, height: 2).to_s

    assert_includes chart, "  │\n  │ ⣀⣀⣀⣀\n"
  end

  def test_that_the_chart_colors_a_falling_history_red
    history = Ambito::History.new(
      dollar: Ambito::Dollar.find(:bna),
      quotes: {Date.new(2026, 11, 1) => 100.0, Date.new(2026, 11, 8) => 93.0}
    )

    chart = Ambito::Chart.new(history, width: 4, height: 2, color: true).to_s

    assert_includes chart, "\e[36mBNA\e[0m  01/11/2026 – 08/11/2026  \e[31m-7.00%\e[0m"
    assert_includes chart, "\e[2mCambio:\e[0m \e[31m-7.00\e[0m (\e[31m-7.00%\e[0m)"
  end

  def test_that_the_cli_charts_the_last_30_days_of_a_single_dollar
    stub_ambito_history :bna, from: "2026-10-26", to: "2026-11-25"

    out, = capture_io { Ambito::CLI.new(%w[-d bna], now: NOW).run }

    assert_equal 25, out.lines.size
    assert_equal "BNA  27/10/2026 – 26/11/2026  +3.83%\n", out.lines.first
    assert_equal "Cambio: +60.00 (+3.83%)\n", out.lines.last
  end

  def test_that_the_cli_charts_between_two_dates
    stub_ambito_history :bna, from: "2026-01-01", to: "2026-06-30"

    out, = capture_io { Ambito::CLI.new(%w[-d bna --from 2026-01-01 --to 2026-06-30], now: NOW).run }

    assert_equal 25, out.lines.size
  end

  def test_that_the_cli_charts_the_30_days_before_the_last_date
    stub_ambito_history :bna, from: "2026-05-31", to: "2026-06-30"

    out, = capture_io { Ambito::CLI.new(%w[-d bna --to 2026-06-30], now: NOW).run }

    assert_equal 25, out.lines.size
  end

  def test_that_the_cli_charts_from_a_date_until_today
    stub_ambito_history :bna, from: "2026-01-01", to: "2026-11-25"

    out, = capture_io { Ambito::CLI.new(%w[-d bna --from 2026-01-01], now: NOW).run }

    assert_equal 25, out.lines.size
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
