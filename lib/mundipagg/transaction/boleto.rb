module Mundipagg
  module Transaction
    class Boleto
      include ActiveModel::Model

      attr_accessor :amount, :order_id

      def to_message
        {
          boleto_transaction_collection: {
            boleto_transaction: {
              amount_in_cents: amount,
              bank_number: Mundipagg.bank_number,
              days_to_add_in_boleto_expiration_date: Mundipagg.days_to_expire,
              nosso_numero: Mundipagg.bank_code,
              transaction_reference: order_id
            }
          }
        }
      end
    end
  end
end
