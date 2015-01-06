require "mundipagg/key"

module Mundipagg
  class Message
    def initialize(hash)
      @hash = hash
    end

    def translate
      @hash.inject(Hash.new) do |hash, (key, value)|
        key = Mundipagg::Key.new(key).to_s

        hash[key] = value.is_a?(Hash) ? self.class.new(value).translate : value
        hash
      end
    end
  end
end
