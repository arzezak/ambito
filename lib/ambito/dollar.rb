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
      buy, sell, variation = gateway.get("compra", "venta", "variacion")

      Rate.new(dollar: self, buy:, sell:, variation:)
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

      def where(name: nil)
        name && find(name) || all
      end
    end
  end
end
