# frozen_string_literal: true

require_relative "ambito/cli"
require_relative "ambito/dollar"
require_relative "ambito/gateway"
require_relative "ambito/rate"
require_relative "ambito/version"

module Ambito
  class << self
    def rates
      Dollar.all.map(&:rate)
    end

    def rate(dollar)
      Dollar.find(dollar).rate
    end
  end
end
