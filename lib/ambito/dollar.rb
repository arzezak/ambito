require "yaml"

module Ambito
  class Dollar
    LIST = YAML.safe_load_file(
      "./config/dollars.yml",
      permitted_classes: [Ambito::Dollar]
    ).freeze

    attr_reader :name, :display, :endpoint

    def initialize(name:, display:, endpoint:)
      @name = name
      @display = display
      @endpoint = endpoint
    end

    def rate
      gateway = Gateway.new(endpoint:)
      buy, sell, value, variation = gateway.get("compra", "venta", "valor", "variacion")

      Rate.new(dollar: self, buy:, sell:, value:, variation:)
    end

    def to_s
      display
    end

    class << self
      def all
        LIST
      end

      def find(name)
        LIST.find do |dollar|
          dollar.name == String(name)
        end
      end
    end
  end
end
