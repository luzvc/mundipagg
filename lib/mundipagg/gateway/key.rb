require "active_support/core_ext/string/conversions"

module Mundipagg
  module Gateway
    class Key
      def initialize(prefix, value)
        @prefix, @value = prefix, value.to_s
      end

      def to_s
        "#{@prefix}:#{camelize}"
      end

      def camelize
        @value.camelize(format)
      end

      def format
        @prefix == "tns" ? :lower : :upper
      end
    end
  end
end
