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
