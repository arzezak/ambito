# frozen_string_literal: true

require "test_helper"
require "test_stubs"

class TestAmbito < Minitest::Test
  include TestStubs

  def test_that_it_has_a_version_number
    refute_nil ::Ambito::VERSION
  end

  def test_that_it_returns_rates
    Ambito.fetch.each do |rate|
      assert_kind_of Numeric, rate.average
    end
  end

  def test_that_it_returns_a_formatted_string
    assert_equal <<~OUTPUT.chomp, Ambito.fetch.join("\n")
      Oficial: $ 363.71 📈 0.58%
      Informal: $ 1050.00 📈 13.16%
      MEP: $ 930.44 📈 6.60%
    OUTPUT
  end
end
