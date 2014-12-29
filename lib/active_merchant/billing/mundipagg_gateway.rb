module ActiveMerchant
  module Billing
    class MundipaggGateway < Gateway
      def initialize(options={})
        requires!(options, :merchant_key)
        super
      end

      def purchase(amount, payment)
        client = ::Mundipagg::Gateway::Client.new

        payment.merchant_key = options[:merchant_key]
        transaction = payment.payload(amount)

        response_payload = client.call(:create_order, :create_order_request, transaction)
        response = payment.class.const_get("Response").new(response_payload.body)

        response
      end

      def refund(amount, order)
        client = ::Mundipagg::Gateway::Client.new

        order.merchant_key = options[:merchant_key]
        transaction = order.payload(amount)

        response_payload = client.call(:manage_order, :manage_order_request, transaction)
        response = order.class.const_get("Response").new(response_payload.body)

        response
      end
    end
  end
end
