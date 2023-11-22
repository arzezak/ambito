# frozen_string_literal: true

require "test_helper"

class TestAmbito < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Ambito::VERSION
  end

  def test_that_it_returns_rates
    Ambito.fetch.each do |rate|
      assert_kind_of Numeric, rate.average
    end
  end
end
