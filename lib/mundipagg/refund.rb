module Mundipagg
  class Refund < ActiveMerchant::Billing::Model
    attr_accessor :transaction_key, :order_key, :merchant_key

    def payload(amount)
      {
        manage_credit_card_transaction_collection: {
          manage_credit_card_transaction_request: {
            amount_in_cents: amount,
            transaction_key: transaction_key
          }
        },
        manage_order_operation_enum: "Void",
        merchant_key: merchant_key,
        order_key: order_key
      }
    end

    class Response
      attr_reader :payload

      def initialize(payload = {})
        @payload = payload[:manage_order_response][:manage_order_result]
      end

      def result
        payload
      end

      def success?
        payload[:success]
      end

      def error
        error_item = result[:error_report][:error_item_collection][:error_item]
        message = error_item[:description]
        code = error_item[:error_code]

        ::Mundipagg::Error.new message, code
      end
    end
  end
end
