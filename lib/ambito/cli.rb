require "optparse"

module Ambito
  class CLI
    def initialize(argv)
      @argv = argv
    end

    def run
      case options
      in {dollar:}
        puts Ambito.rate(dollar)
      in {version: true}
        puts Ambito::VERSION
      else
        puts Ambito.rates
      end
    end

    private

    def options
      {}.tap do |parsed_options|
        OptionParser.new do |options|
          options.on("-d", "--dollar DOLLAR", "Select the rate") do |dollar|
            parsed_options[:dollar] = dollar
          end
          options.on("-v", "--version", "Show version") do
            parsed_options[:version] = true
          end
        end.parse(@argv)
      end
    end
  end
end
