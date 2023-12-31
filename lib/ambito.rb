# frozen_string_literal: true

require_relative "ambito/cli"
require_relative "ambito/dollar"
require_relative "ambito/gateway"
require_relative "ambito/price"
require_relative "ambito/rate"
require_relative "ambito/variation"
require_relative "ambito/version"

module Ambito
  class << self
    def rates
      Dollar.all.map do |dollar|
        Thread.new do
          dollar.rate
        end
      end.map(&:value)
    end

    def rate(dollar)
      Dollar.find(dollar).rate
    end
  end
end
