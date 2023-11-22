require "optparse"

module Ambito
  class CLI
    def initialize(argv)
      @argv = argv
    end

    def run
      puts options
    end

    private

    def options
      {}.tap do |parsed_options|
        OptionParser.new do |options|
          options.on("-d", "--dollar DOLLAR", "Select the rate") do |dollar|
            parsed_options[:dollar] = dollar
          end
        end.parse(@argv)
      end
    end
  end
end
