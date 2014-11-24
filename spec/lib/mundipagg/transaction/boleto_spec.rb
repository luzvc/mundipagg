RSpec.describe Mundipagg::Transaction::Boleto do
  describe "#to_message" do
    let(:transaction) { described_class.new(order_id: "ORDER_ID", amount: 100) }
    subject { transaction.to_message[:boleto_transaction_collection][:boleto_transaction] }

    before do
      Mundipagg.setup do |config|
        config.bank_code = "BANK_CODE"
      end
    end

    it { is_expected.to include amount_in_cents: 100 }
    it { is_expected.to include bank_number: 341 }
    it { is_expected.to include days_to_add_in_boleto_expiration_date: 5 }
    it { is_expected.to include nosso_numero: "BANK_CODE" }
    it { is_expected.to include transaction_reference: "ORDER_ID" }
  end
end
