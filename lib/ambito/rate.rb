module Ambito
  class Rate
    attr_reader :name, :display, :endpoint

    def initialize(name:, display:, endpoint:)
      @name = name
      @display = display
      @endpoint = endpoint
    end
  end
end
