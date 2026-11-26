# frozen_string_literal: true

require_relative "ambito/age"
require_relative "ambito/chart"
require_relative "ambito/cli"
require_relative "ambito/dollar"
require_relative "ambito/gateway"
require_relative "ambito/history"
require_relative "ambito/price"
require_relative "ambito/rate"
require_relative "ambito/table"
require_relative "ambito/variation"
require_relative "ambito/version"

module Ambito
  Error = Class.new(StandardError)

  class << self
    def rates
      Dollar.all.map do |dollar|
        Thread.new do
          Thread.current.report_on_exception = false
          fetch(dollar)
        end
      end.map(&:value)
    end

    def rate(name)
      fetch(Dollar.find(name))
    end

    def history(name, from:, to:)
      Gateway.new(Dollar.find(name)).history(from:, to:)
    end

    private

    def fetch(dollar)
      Gateway.new(dollar).rate
    end
  end
end
