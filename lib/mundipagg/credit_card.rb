module Mundipagg
  class CreditCard < ActiveMerchant::Billing::CreditCard
    attr_accessor :installment_count
    mattr_accessor :mode

    @@mode = :test

    def self.test?
      mode == :test
    end

    def brand_name
      name = brand
      name = "mastercard" if name == "master"

      name.capitalize
    end

    def payload(amount)
      content = {
        amount_in_cents: amount,
        credit_card_brand_enum: brand_name,
        exp_month: month,
        exp_year: year,
        holder_name: name,
        installment_count: installment_count || 1,
        credit_card_number: number,
        security_code: verification_value,
        credit_card_operation_enum: "AuthAndCapture"
      }

      if ::ActiveMerchant::Billing::Base.test?
        content.merge!(payment_method_code: 1)
      end

      {
        credit_card_transaction_collection: { credit_card_transaction: content }
      }
    end
  end
end
