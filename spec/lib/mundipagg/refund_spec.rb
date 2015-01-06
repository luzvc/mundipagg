require "spec_helper"

RSpec.describe Mundipagg::Refund do
  describe "#payload" do
    let(:refund) do
      described_class.new transaction_key: "TRANSACTION-KEY",
        order_key: "ORDER-KEY"
    end

    it do
      expect(refund.payload(100)).to eq({
        manage_credit_card_transaction_collection: {
          manage_credit_card_transaction_request: {
            amount_in_cents: 100,
            transaction_key: "TRANSACTION-KEY"
          }
        },

        manage_order_operation_enum: "Void",
        order_key: "ORDER-KEY"
      })
    end
  end
end

RSpec.describe Mundipagg::Refund::Response do
  let(:body) do
    {
      manage_order_response: {
        manage_order_result: {
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
