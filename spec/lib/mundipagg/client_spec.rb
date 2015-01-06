RSpec.describe Mundipagg::Client do
  describe "#adapter" do
    subject { described_class.new.adapter }

    it { expect(subject.globals[:wsdl]).to eq("https://transaction.mundipaggone.com/MundiPaggService.svc?wsdl") }
    it { expect(subject.globals[:namespaces]).to eq("xmlns:mun" => "http://schemas.datacontract.org/2004/07/MundiPagg.One.Service.DataContracts") }
  end

  describe "#call" do
    let(:gateway) { described_class.new }

    it "sends a message" do
      expect(gateway.adapter).to receive(:call) do |operation, options|
        expect(operation).to eq("create_order")
        expect(options).to include(message: {
          "tns:createOrderRequest" => { "mun:Test" => "works" }
        })
      end

      gateway.call("create_order", "create_order_request", { test: "works" })
    end
  end

  describe "#manage_order" do
    let(:merchant_key) { "MERCHANT-KEY" }
    let(:gateway) { described_class.new }
    let(:message) {
      {
        manage_credit_card_transaction_collection: {
          manage_credit_card_transaction_request: {
            amount_in_cents: 1,
            transaction_key: "e4c764a4-8ea9-499b-9dd9-25fd4f0a7202"
          }
        },
        manage_order_operation_enum: "Void",
        merchant_key: merchant_key,
        order_key: "0562f9ed-a578-4b4a-9e60-db9c9b25f625"
      }
    }

    let(:response) { gateway.manage_order(message) }
    let(:result) { response.body[:manage_order_response][:manage_order_result] }

    it "sends a manager order command", :vcr do
      expect(result[:success]).to be_truthy
    end
  end

  describe "#create_order" do
    let(:merchant_key) { "MERCHANT-KEY" }
    let(:gateway) { described_class.new }
    let(:message) {
      {
        amount_in_cents: 1,
        currency_iso_enum: "BRL",
        merchant_key: merchant_key,
        credit_card_transaction_collection: {
          credit_card_transaction: {
            amount_in_cents: 1,
            credit_card_brand_enum: "Mastercard",
            credit_card_number: "5555666677778884",
            credit_card_operation_enum: "AuthAndCapture",
            exp_month: 10, exp_year: 2019,
            holder_name: "Bruno Azisaka Maciel",
            installment_count: 1,
            security_code: "123"
          }
        }
      }
    }

    let(:response) { gateway.create_order(message) }
    let(:result) { response.body[:create_order_response][:create_order_result] }

    it "sends a create order command", :vcr do
      expect(result[:success]).to be_truthy
    end
  end
end
