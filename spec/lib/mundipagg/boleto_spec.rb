require "spec_helper"

RSpec.describe Mundipagg::Boleto do
  describe "#payload" do
    let(:boleto) do
      described_class.new bank_number: 347, bank_code: 123456,
        instructions: "Pedido #123456",
        document_number: "123", document_type: "cpf", name: "Buyer Name",
        person_Type: "fisica", complement: "apt 1", city: "Sao Paulo",
        country: "Brasil", district: "Centro", number: "1", state: "Sao Paulo",
        street: "Rua 1", zip_code: "00000-000"
    end

    it do
      expect(boleto.payload(100)).to eq({
        amount_in_cents: 100,
        currency_iso_enum: "BRL",
        boleto_transaction_collection: [
          {
            amount_in_cents: 100,
            bank_number: 347,
            days_to_add_in_boleto_expiration_date: 5,
            nosso_numero: 123456,
            instructions: "Pedido #123456"
          }
        ],
        buyer: {
          document_number: "123",
          document_type: "cpf",
          name: "Buyer Name",
          person_type: "fisica",
          address_collection: [
            {
              address_type: "residencial",
              complement: "apt 1",
              city: "Sao Paulo",
              country: "Brasil",
              district: "Centro",
              number: "1",
              state: "Sao Paulo",
              street: "Rua 1",
              zip_code: "00000-000"
            }
          ]
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
