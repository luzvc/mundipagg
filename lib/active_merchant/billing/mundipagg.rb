module ActiveMerchant
  module Billing
    class MundipaggGateway < Gateway
      def initialize(options={})
        requires!(options, :merchant_key)
        super
      end

      def purchase(amount, payment, options = {})
        client = Mundipagg::Gateway::Client.new

        transaction = payload(amount, payment.payload(amount))
        client.call(:create_order, :create_order_request, transaction)
      end

      def payload(amount, extra_attributes = {})
        {
          amount_in_cents: amount,
          currency_iso_enum: "BRL",
          merchant_key: options[:merchant_key]
        }.merge(extra_attributes)
      end
    end
  end
end
