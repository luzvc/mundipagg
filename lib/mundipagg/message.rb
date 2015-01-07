require "mundipagg/key"

module Mundipagg
  class Message
    def initialize(hash)
      @hash = hash
    end

    def translate
      @hash.each_with_object(Hash.new) do |(key, value), hash|
        key = Mundipagg::Key.new(key).to_s
        hash[key] = value.is_a?(Hash) ? self.class.new(value).translate : value
      end
    end
  end
end
