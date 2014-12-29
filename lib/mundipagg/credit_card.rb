module Mundipagg
  class CreditCard < ActiveMerchant::Billing::CreditCard
    attr_accessor :installment_count, :merchant_key

    def brand_name
      name = brand
      name = "mastercard" if name == "master"

      name.capitalize
    end

    def payload(amount)
      content = {
        amount_in_cents: amount,
        credit_card_brand_enum: brand_name,
        credit_card_number: number,
        credit_card_operation_enum: "AuthAndCapture",
        exp_month: month,
        exp_year: year,
        holder_name: name,
        installment_count: installment_count || 1,
        security_code: verification_value,
      }

      if ::ActiveMerchant::Billing::Base.test?
        content.merge!(payment_method_code: 1)
      end

      {
        amount_in_cents: amount,
        currency_iso_enum: "BRL",
        merchant_key: merchant_key,

        credit_card_transaction_collection: {
          credit_card_transaction: content
        }
      }
    end

    class Response
      attr_reader :payload

      def initialize(payload = {})
        @payload = payload[:create_order_response][:create_order_result]
      end

      def result
        payload[:credit_card_transaction_result_collection][:credit_card_transaction_result]
      end

      def success?
        payload[:success]
      end

      def error
        message = result[:acquirer_message].split("|").last
        code = result[:acquirer_return_code]

        ::Mundipagg::Error.new message, code
      end
    end
  end
end
