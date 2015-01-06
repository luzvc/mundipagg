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

      response = client.send(method, payload)
      object.class::Response.new(response.body)
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
