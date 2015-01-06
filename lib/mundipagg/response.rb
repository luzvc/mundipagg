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

    alias :valid? :success?

    def error
      ::Mundipagg::Error.new error_item[:description], error_item[:error_code]
    rescue NoMethodError
      nil
    end

    def error_item
      raise "Not yet implemented"
    end
  end
end