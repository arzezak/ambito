# frozen_string_literal: true

require "test_helper"
require "test_stubs"

class TestAmbito < Minitest::Test
  include TestStubs

  def test_that_it_has_a_version_number
    refute_nil ::Ambito::VERSION
  end

  def test_that_it_returns_a_formatted_string
    assert_equal <<~OUTPUT.chomp, Ambito.rates.join("\n")
      Oficial: $ 363.71 📈 0.58%
      Informal: $ 1050.00 📊 0.00%
      MEP: $ 930.44 📉 -6.60%
      Cripto: $ 978.64 📉 -0.01%
    OUTPUT
  end

  def test_that_it_includes_emoji_reflecting_upward_trends
    assert_includes Ambito.rate(dollar: "oficial").to_s, "📈"
  end

  def test_that_it_includes_emoji_reflecting_downward_trends
    assert_includes Ambito.rate(dollar: "mep").to_s, "📉"
  end

  def test_that_it_includes_emoji_reflecting_stable_trends
    assert_includes Ambito.rate(dollar: "informal").to_s, "📊"
  end
end
