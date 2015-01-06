module Mundipagg
  class Gateway < ActiveMerchant::Billing::Gateway
    def initialize(options={})
      requires! options, :merchant_key
      super
    end

    def purchase(amount, object)
      call amount, object, :create_order
    end

    def refund(amount, object)
      call amount, object, :manage_order
    end

    private
    def call(amount, object, method)
      payload = apply_merchant_key object.payload(amount)

      result = client.send(method, payload)
      response = object.class::Response.new(result.body)

      params = { body: result.body }

      if response.success?
        message = "Ok"
      else
        message = response.error.message
        params.merge! error_code: response.error.code
      end

      ActiveMerchant::Billing::Response.new response.success?, message, params
    end

    def apply_merchant_key(body)
      payload = body.to_a
      payload.insert(-2, [ :merchant_key, options[:merchant_key] ])

      payload.each_with_object({}) { |(k, v), h| h[k] = v }
    end

    def client
      @client ||= ::Mundipagg::Client.new
    end
  end
end
