module Mundipagg
  class CreditCard < ActiveMerchant::Billing::CreditCard
    attr_accessor :installment_count

    def brand_name
      return "" if !brand.present?

      case brand
      when "master"
        "Mastercard"
      when "american_express"
        "Amex"
      else
        brand.capitalize
      end
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
        credit_card_transaction_collection: { credit_card_transaction: content }
      }
    end

    class Response < Mundipagg::Response
      def payload
        body[:create_order_response][:create_order_result]
      end

      def error_item
        { description: error_description, error_code: acquirer_return_code }
      end

      def error_description
        code = acquirer_message_code

        default_message = case code
        when "1000"
          "Transação não autorizada."
        when "1011"
          "Cartão inválido."
        when "1013"
          "Transação não autorizada."
        when "1025"
          "Cartão bloqueado."
        when "2001"
          "Cartão vencido."
        when "9111"
          "Time-out na transação."
        else
          "Transação não autorizada. Código %{code}."
        end

        I18n.t code, scope: "mundipagg.errors",
          default: default_message,
          code: acquirer_message_code,
          acquirer_message: acquirer_message
      end

      def acquirer_return_code
        payload[:credit_card_transaction_result_collection][:credit_card_transaction_result][:acquirer_return_code]
      end

      def acquirer_message_code
        @acquirer_message_code ||= acquirer_message.split("|").last
      end

      def acquirer_message
        payload[:credit_card_transaction_result_collection][:credit_card_transaction_result][:acquirer_message]
      end
    end
  end
end
