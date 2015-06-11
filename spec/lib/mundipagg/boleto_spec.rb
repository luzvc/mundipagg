require "spec_helper"

RSpec.describe Mundipagg::Boleto do
  describe "#payload" do
    let(:boleto) do
      described_class.new bank_number: 347,
        bank_code: 123456, instructions: "Pedido #123456"
    end

    it do
      expect(boleto.payload(100)).to eq({
        amount_in_cents: 100,
        currency_iso_enum: "BRL",
        boleto_transaction_collection: {
          boleto_transaction: {
            amount_in_cents: 100,
            bank_number: 347,
            days_to_add_in_boleto_expiration_date: 5,
            nosso_numero: 123456,
            instructions: "Pedido #123456"
          }
        }
      })
    end
  end
end

RSpec.describe Mundipagg::Boleto::Response do
  let(:body) do
    {
      create_order_response: {
        create_order_result: {
          error_report: {
            error_item_collection: {
              error_item: {
                description: "Out of Money",
                error_code: "E666"
              }
            }
          }
        }
      }
    }
  end

  let(:response) { described_class.new body }

  describe "#payload" do
    it do
      expect(response.payload).to eq({
        error_report: {
          error_item_collection: {
            error_item: {
              description: "Out of Money",
              error_code: "E666"
            }
          }
        }
      })
    end
  end

  describe "#error" do
    it { expect(response.error).to be_a(Mundipagg::Error) }
    it { expect(response.error.code).to eq("E666") }
    it { expect(response.error.message).to eq("Out of Money") }
  end
end
