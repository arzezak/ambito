require "yaml"

module Ambito
  class Dollar
    LIST = YAML.safe_load_file(
      "#{__dir__}/../../config/dollars.yml",
      permitted_classes: [Ambito::Dollar]
    ).freeze

    attr_reader :name, :display, :endpoint

    def initialize(name:, display:, endpoint:)
      @name = name
      @display = display
      @endpoint = endpoint
    end

    def to_s
      display
    end

    class << self
      def all
        LIST
      end

      def find(name)
        LIST.find { |dollar| dollar.name == String(name) } ||
          raise(Error, "Unknown dollar: #{name}")
      end
    end
  end
end
