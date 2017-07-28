module Mundipagg
  class Boleto < ActiveMerchant::Billing::Model
    attr_accessor :bank_number, :days_to_expire, :bank_code, :instructions,
      :complement, :city, :country, :district, :number, :state, :street,
      :zip_code, :document_number, :document_type, :name, :person_type

    def payload(amount)
      {
        amount_in_cents: amount,
        currency_iso_enum: "BRL",
        boleto_transaction_collection: {
          boleto_transaction: payload_transaction_collection(amount)
        },
        buyer: payload_buyer
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

    private

    def payload_transaction_collection(amount)
      {
        amount_in_cents: amount,
        bank_number: bank_number,
        days_to_add_in_boleto_expiration_date: days_to_expire || 5,
        instructions: instructions,
        nosso_numero: bank_code
      }
    end

    def payload_buyer
      {
        document_number: document_number,
        document_type: document_type,
        name: name,
        person_type: person_type,
        address_collection: [ payload_address_collection ]
      }
    end

    def payload_address_collection
      {
        address_type: "residencial",
        complement: complement,
        city: city,
        country: country,
        district: district,
        number: number,
        state: state,
        street: street,
        zip_code: zip_code
      }
    end
  end
end
