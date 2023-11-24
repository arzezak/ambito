# frozen_string_literal: true

require "test_helper"

class TestAmbito < Minitest::Test
  include TestHelper

  def test_that_it_has_a_version_number
    refute_nil ::Ambito::VERSION
  end

  def test_that_it_returns_a_formatted_string
    stub_ambito_request to: "dolar/oficial", with: fixture(:oficial)
    stub_ambito_request to: "dolar/informal", with: fixture(:informal)
    stub_ambito_request to: "dolarrava/mep", with: fixture(:mep)
    stub_ambito_request to: "dolarcripto", with: fixture(:cripto)

    assert_equal <<~OUTPUT.chomp, Ambito.rates.join("\n")
      Oficial: $ 363.71 📈 0.58%
      Informal: $ 1050.00 📊 0.00%
      MEP: $ 930.44 📉 -6.60%
      Cripto: $ 978.64 📉 -0.01%
    OUTPUT
  end

  def test_that_it_includes_emoji_reflecting_upward_trends
    stub_ambito_request(
      to: "dolar/oficial",
      with: fixture(:oficial),
      override: {"variacion" => "0,23%"}
    )

    assert_includes Ambito.rate(:oficial).to_s, "📈"
  end

  def test_that_it_includes_emoji_reflecting_downward_trends
    stub_ambito_request(
      to: "dolar/oficial",
      with: fixture(:oficial),
      override: {"variacion" => "-0,23%"}
    )

    assert_includes Ambito.rate(:oficial).to_s, "📉"
  end

  def test_that_it_includes_emoji_reflecting_stable_trends
    stub_ambito_request(
      to: "dolar/oficial",
      with: fixture(:oficial),
      override: {"variacion" => "0,00%"}
    )

    assert_includes Ambito.rate(:oficial).to_s, "📊"
  end
end
