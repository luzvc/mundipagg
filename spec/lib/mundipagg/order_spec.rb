RSpec.describe Mundipagg::Order do
  describe "validation" do
    it "validates presence of id" do
      subject.valid?
      expect(subject.errors[:id]).to include("can't be blank")
    end

    it "validates presence of transaction" do
      subject.valid?
      expect(subject.errors[:transaction]).to include("can't be blank")
    end
  end

  describe "#to_message" do
    before do
      Mundipagg.setup do |config|
        config.merchant_key = "MERCHANT_KEY"
        config.bank_code = "BANK_NUMBER"
      end
    end

    let(:transaction) { Mundipagg::Transaction::Boleto.new(amount: 100) }
    let(:order) { described_class.new id: "ORDER_ID", transaction: transaction }

    subject { order.to_message }

    it { is_expected.to include(amount_in_cents: 100) }
    it { is_expected.to include(currency_iso_enum: "BRL") }
    it { is_expected.to include(merchant_key: "MERCHANT_KEY") }
    it { is_expected.to have_key(:boleto_transaction_collection) }

    context "boleto_transaction_collection" do
      subject { order.to_message[:boleto_transaction_collection][:boleto_transaction] }
      it { is_expected.to include(amount_in_cents: 100) }
      it { is_expected.to include(bank_number: 341) }
      it { is_expected.to include(days_to_add_in_boleto_expiration_date: 5) }
      it { is_expected.to include(nosso_numero: "BANK_NUMBER") }
      it { is_expected.to include(transaction_reference: "ORDER_ID") }
    end
  end

  describe "#create" do
    let(:client) { double "client" }
    let(:order) { described_class.new }

    it "sends a message through the gateway client" do
      expect(order).to receive(:to_message).and_return({ "mun:Message" => "ok" })
      expect(Mundipagg::Gateway::Client).to receive(:new).and_return(client)
      expect(client).to receive(:call).with(:create_order, :create_order_request, { "mun:Message" => "ok" })

      order.create
    end
  end
end
