require "spec_helper"

RSpec.describe Mundipagg::Gateway do
  let(:gateway) { described_class.new merchant_key: "MERCHANT-KEY" }
  let(:client) { double "client" }

  before do
    allow(Mundipagg::Client).to receive(:new).and_return(client)
  end

  describe "#purchase" do
    let(:boleto) { Mundipagg::Boleto.new bank_number: 123, bank_code: 987 }
    let(:body) {
      {
        create_order_response: {
          create_order_result: {
            success: true
          }
        }
      }
    }

    let(:gateway_response) { double "gateway_response", body: body }

    it "sends a create order and returns the response" do
      expect(client).to receive(:create_order).with({
        amount_in_cents: 100,
        currency_iso_enum: "BRL",
        merchant_key: "MERCHANT-KEY",
        boleto_transaction_collection: {
          boleto_transaction: {
            amount_in_cents: 100,
            bank_number: 123,
            days_to_add_in_boleto_expiration_date: 5,
            nosso_numero: 987
          }
        }
      }).and_return(gateway_response)

      response = gateway.purchase(100, boleto)
      expect(response).to be_a(ActiveMerchant::Billing::Response)
      expect(response).to be_success
    end
  end

  describe "#refund" do
    let(:refund) do
      Mundipagg::Refund.new transaction_key: "TRANSACTION-KEY",
        order_key: "ORDER-KEY"
    end

    let(:body) do
      {
        manage_order_response: {
          manage_order_result: {
            success: true
          }
        }
      }
    end

    let(:gateway_response) { double "gateway_response", body: body }

    it "sends a manage order and returns the response" do
      expect(client).to receive(:manage_order).with({
        manage_credit_card_transaction_collection: {
          manage_credit_card_transaction_request: {
            amount_in_cents: 100,
            transaction_key: "TRANSACTION-KEY"
          }
        },
        manage_order_operation_enum: "Void",
        merchant_key: "MERCHANT-KEY",
        order_key: "ORDER-KEY"
      }).and_return(gateway_response)

      response = gateway.refund(100, refund)
      expect(response).to be_a(ActiveMerchant::Billing::Response)
      expect(response).to be_success
    end
  end
end
