module Mundipagg
  class Boleto < ActiveMerchant::Billing::Model
    attr_accessor :bank_number, :days_to_expire, :bank_code, :instructions

    def payload(amount)
      content = {
        amount_in_cents: amount,
        bank_number: bank_number,
        days_to_add_in_boleto_expiration_date: days_to_expire || 5,
        nosso_numero: bank_code,
        instructions: instructions
      }

      {
        amount_in_cents: amount,
        currency_iso_enum: "BRL",
        boleto_transaction_collection: { boleto_transaction: content }
      }
    end

    class Response < Mundipagg::Response
      def payload
        body[:create_order_response][:create_order_result]
      end

      def error_item
        payload[:error_report][:error_item_collection][:error_item]
      end
    end
  end
end
