require "date"
require "optparse"

module Ambito
  class CLI
    CHART_DAYS = 30

    def initialize(argv, now: Time.now)
      @argv = argv
      @now = now
    end

    def run
      case options
      in {dollar:}
        puts chart(dollar)
      in {version: true}
        puts Ambito::VERSION
      else
        puts table(Ambito.rates)
      end
    rescue Error => e
      abort e.message
    end

    private

    def chart(dollar)
      today = @now.to_date

      Chart.new(Ambito.history(dollar, from: today - CHART_DAYS, to: today), color: $stdout.tty?)
    end

    def table(rates)
      Table.new(rates, now: @now, color: $stdout.tty?)
    end

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
