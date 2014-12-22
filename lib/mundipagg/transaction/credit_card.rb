require "active_merchant"

module Mundipagg
  module Transaction
    class CreditCard
      include ActiveModel::Model

      attr_accessor :amount, :month, :year, :first_name, :last_name,
        :installment_count, :number, :verification_value, :order_id

      validates :first_name, :last_name, :number, :verification_value,
        presence: true

      validates :installment_count, inclusion: { in: (1..6) }

      def to_message
        {
          credit_card_transaction_collection: {
            credit_card_transaction: {
              # payment_method_code: 1,
              amount_in_cents: amount,
              credit_card_brand_enum: brand,
              exp_month: month,
              exp_year: year,
              holder_name: holder_name,
              installment_count: installment_count || 1,
              credit_card_number: number,
              security_code: verification_value,
              credit_card_operation_enum: "AuthOnly",
            }
          }
        }
      end

      def holder_name
        "#{first_name} #{last_name}"
      end

      def brand
        ActiveMerchant::Billing::CreditCard.brand?(number)
      end

      def merchant_card
        ActiveMerchant::Billing::CreditCard.new first_name: first_name,
          last_name: last_name,
          number: number,
          verification_value: verification_value
      end
    end
  end
end
