module Mundipagg
  class Boleto < ActiveMerchant::Billing::Model
    attr_accessor :merchant_key, :bank_number, :days_to_expire, :bank_code

    def payload(amount)
      {
        amount_in_cents: amount,
        currency_iso_enum: "BRL",
        merchant_key: merchant_key,

        boleto_transaction_collection: {
          boleto_transaction: {
            amount_in_cents: amount,
            bank_number: bank_number || Mundipagg.bank_number,
            days_to_add_in_boleto_expiration_date: days_to_expire || 5,
            nosso_numero: bank_code || Mundipagg.bank_code
          }
        }
      }
    end

    class Response
      attr_reader :payload

      def initialize(payload)
        @payload = payload[:create_order_response][:create_order_result]
      end

      def result
        payload[:boleto_transaction_result_collection][:boleto_transaction_result]
      end

      def success?
        payload[:success]
      end

      def error
        error_item = payload[:error_report][:error_item_collection][:error_item]
        message = error_item[:description]
        code = error_item[:error_code]

        ::Mundipagg::Error.new message, code
      end
    end
  end
end
