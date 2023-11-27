# frozen_string_literal: true

require "test_helper"

class TestAmbito < Minitest::Test
  include TestHelper

  def test_that_it_has_a_version_number
    refute_nil ::Ambito::VERSION
  end

  def test_that_it_returns_a_formatted_string
    stub_ambito_request :oficial
    stub_ambito_request :informal
    stub_ambito_request :mep
    stub_ambito_request :cripto
    stub_ambito_request :turista
    stub_ambito_request :ccl

    assert_equal <<~OUTPUT.chomp, Ambito.rates.join("\n")
      CCL: $ 858.28 📉 -7.10%
      Cripto: $ 980.98 📈 0.01%
      Informal: $ 970.00 📉 -4.78%
      MEP: $ 972.75 📉 -3.30%
      Oficial: $ 365.38 📈 0.23%
      Turista: $ 960.56 📈 0.35%
    OUTPUT
  end

  def test_that_it_includes_emoji_reflecting_upward_trends
    stub_ambito_request :oficial, override: {variacion: "0,23%"}

    assert_includes Ambito.rate(:oficial).to_s, "📈"
  end

  def test_that_it_includes_emoji_reflecting_downward_trends
    stub_ambito_request :oficial, override: {variacion: "-0,23%"}

    assert_includes Ambito.rate(:oficial).to_s, "📉"
  end

  def test_that_it_includes_emoji_reflecting_stable_trends
    stub_ambito_request :oficial, override: {variacion: "0,00%"}

    assert_includes Ambito.rate(:oficial).to_s, "📊"
  end

  def test_that_it_uses_value_when_available
    stub_ambito_request :oficial, override: {valor: "462,13"}

    assert_includes Ambito.rate(:oficial).to_s, "$ 462.13"
  end
end
