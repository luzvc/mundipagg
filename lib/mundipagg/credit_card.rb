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
        case acquirer_message_code
        when "1000"
          I18n.t("1000", scope: "mundipagg.errors", default: "Transação não autorizada.")
        when "1011"
          I18n.t("1011", scope: "mundipagg.errors", default: "Cartão inválido.")
        when "1013"
          I18n.t("1013", scope: "mundipagg.errors", default: "Transação não autorizada.")
        when "1025"
          I18n.t("1025", scope: "mundipagg.errors", default: "Cartão bloqueado.")
        when "2001"
          I18n.t("2001", scope: "mundipagg.errors", default: "Cartão vencido.")
        when "9111"
          I18n.t("9111", scope: "mundipagg.errors", default: "Time-out na transação.")
        else
          I18n.t("default", scope: "mundipagg.errors", default: "Transação não autorizada.")
        end
      end

      def acquirer_return_code
        payload[:credit_card_transaction_result_collection][:credit_card_transaction_result][:acquirer_return_code]
      end

      def acquirer_message_code
        @acquirer_message_code ||= payload[:credit_card_transaction_result_collection][:credit_card_transaction_result][:acquirer_message].split("|").last
      end
    end
  end
end
