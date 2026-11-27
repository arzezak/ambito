require "date"
require "optparse"
require "optparse/date"

module Ambito
  class CLI
    CHART_DAYS = 30

    def initialize(argv, now: Time.now)
      @argv = argv
      @now = now
    end

    def run
      case options
      in {dollar:, from:, to:}
        puts chart(dollar, from:, to:)
      in {version: true}
        puts Ambito::VERSION
      else
        puts table(Ambito.rates)
      end
    rescue Error => e
      abort e.message
    end

    private

    def chart(dollar, from:, to:)
      Chart.new(Ambito.history(dollar, from:, to:), color: $stdout.tty?)
    end

    def table(rates)
      Table.new(rates, now: @now, color: $stdout.tty?)
    end

    def options
      {to: @now.to_date}.tap do |parsed_options|
        OptionParser.new do |options|
          options.on("-d", "--dollar DOLLAR", "Chart one rate") do |dollar|
            parsed_options[:dollar] = dollar
          end
          options.on("-f", "--from DATE", Date, "First day of the chart (default: #{CHART_DAYS} days before the last)") do |date|
            parsed_options[:from] = date
          end
          options.on("-t", "--to DATE", Date, "Last day of the chart (default: today)") do |date|
            parsed_options[:to] = date
          end
          options.on("-v", "--version", "Show version") do
            parsed_options[:version] = true
          end
        end.parse(@argv)

        parsed_options[:from] ||= parsed_options[:to] - CHART_DAYS
      end
    end
  end
end
