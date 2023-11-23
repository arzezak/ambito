# frozen_string_literal: true

require "test_helper"
require "test_stubs"

class TestAmbito < Minitest::Test
  include TestStubs

  def test_that_it_has_a_version_number
    refute_nil ::Ambito::VERSION
  end

  def test_that_it_returns_rates
    Ambito.run.each do |dollar|
      assert_kind_of Ambito::Rate, dollar
    end
  end

  def test_that_it_returns_a_formatted_string
    assert_equal <<~OUTPUT.chomp, Ambito.run.join("\n")
      Oficial: $ 363.71 📈 0.58%
      Informal: $ 1050.00 📊 0.00%
      MEP: $ 930.44 📉 -6.60%
    OUTPUT
  end

  def test_that_it_includes_emoji_reflecting_upward_trends
    assert_includes Ambito.run(dollar: "oficial").join, "📈"
  end

  def test_that_it_includes_emoji_reflecting_downward_trends
    assert_includes Ambito.run(dollar: "mep").join, "📉"
  end

  def test_that_it_includes_emoji_reflecting_stable_trends
    assert_includes Ambito.run(dollar: "informal").join, "📊"
  end
end
