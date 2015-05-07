module Mundipagg
  class Response
    attr_reader :body

    alias :payload :body

    def initialize(body = {})
      @body = body
    end

    def success?
      payload[:success]
    end

    def error
      ::Mundipagg::Error.new error_item[:description], error_item[:error_code]
    rescue NoMethodError => event
      ::Mundipagg::Error.new "Unknown error", 0
    end

    def error_item
      raise "Not yet implemented"
    end
  end
end
