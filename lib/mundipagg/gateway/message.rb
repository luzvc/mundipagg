require "mundipagg/gateway/key"

module Mundipagg
  module Gateway
    class Message
      def initialize(hash)
        @hash = hash
      end

      def translate
        @hash.inject(Hash.new) do |hash, (key, value)|
          key = Mundipagg::Gateway::Key.new("mun", key).to_s

          hash[key] = value.is_a?(Hash) ? Message.new(value).translate : value
          hash
        end
      end
    end
  end
end
