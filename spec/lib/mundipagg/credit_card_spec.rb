require "spec_helper"

RSpec.describe Mundipagg::CreditCard do

  describe "#brand_name" do
    let(:credit_card) { described_class.new brand: brand }
    subject { credit_card.brand_name }

    [
      ["master", "Mastercard"],
      ["american_express", "Amex"],
      ["diners_club", "Diners"],
      ["visa", "Visa"],
      [nil, ""]
    ].each do |(input, output)|
      context "when brand is #{input}" do
        let(:brand) { input }
        it { is_expected.to eq output }
      end
    end
  end

  describe "#payload" do
    let(:credit_card) do
      described_class.new installment_count: 2,
        number: "4012001037141112",
        verification_value: "123",
        year: 2020,
        month: 10,
        name: "Bruno Azisaka Maciel"
    end

    context "when under test" do
      before do
        allow(ActiveMerchant::Billing::Base).to receive(:test?).and_return(true)
      end

      it do
        expect(credit_card.payload(100)).to eq({
          amount_in_cents: 100,
          credit_card_transaction_collection: {
            credit_card_transaction: {
              amount_in_cents: 100,
              credit_card_brand_enum: "Visa",
              credit_card_number: "4012001037141112",
              credit_card_operation_enum: "AuthAndCapture",
              exp_month: 10,
              exp_year: 2020,
              holder_name: "Bruno Azisaka Maciel",
              installment_count: 2,
              security_code: "123",
              payment_method_code: 1
            }
          },
          currency_iso_enum: "BRL"
        })
      end
    end

    context "when not under test" do
      before do
        allow(ActiveMerchant::Billing::Base).to receive(:test?).and_return(false)
      end

      it do
        expect(credit_card.payload(100)).to eq({
          amount_in_cents: 100,
          credit_card_transaction_collection: {
            credit_card_transaction: {
              amount_in_cents: 100,
              credit_card_brand_enum: "Visa",
              credit_card_number: "4012001037141112",
              credit_card_operation_enum: "AuthAndCapture",
              exp_month: 10,
              exp_year: 2020,
              holder_name: "Bruno Azisaka Maciel",
              installment_count: 2,
              security_code: "123",
            }
          },
          currency_iso_enum: "BRL"
        })
      end
    end
  end
end

RSpec.describe Mundipagg::CreditCard::Response do
  let(:body) do
    {
      create_order_response: {
        create_order_result: {
          credit_card_transaction_result_collection: {
            credit_card_transaction_result: {
              acquirer_message: "Rede|#{error_code}",
              acquirer_return_code: "E666"
            }
          }
        }
      }
    }
  end

  let(:error_code) { "1000" }

  let(:response) { described_class.new body }

  describe "#payload" do
    it do
      expect(response.payload).to eq({
        credit_card_transaction_result_collection: {
          credit_card_transaction_result: {
            acquirer_message: "Rede|#{error_code}",
            acquirer_return_code: "E666"
          }
        }
      })
    end
  end

  describe "#error" do
    it { expect(response.error).to be_a(Mundipagg::Error) }
    it { expect(response.error.code).to eq("E666") }
    it { expect(response.error.message).to eq("Transação não autorizada.") }
  end

  describe "#error_description" do
    context "using default messages" do
      [
        ["1000", "Transação não autorizada."],
        ["1001", "Cartão com vencimento inválido."],
        ["1011", "Cartão inválido."],
        ["1013", "Transação não autorizada."],
        ["1025", "Cartão bloqueado."],
        ["2001", "Cartão vencido."],
        ["9111", "Time-out na transação."],
        ["WTF", "Transação não autorizada. Código WTF."]
      ].each do |(code, message)|
        context "when the code is #{code}" do
          let(:error_code) { code }
          it { expect(response.error_description).to eq(message) }
        end
      end
    end

    context "translating the messages" do
      before do
        I18n.locale = :pt
      end

      after do
        I18n.locale = I18n.default_locale
      end

      [
        ["1000", "Sua operadora do cartão de crédito não autorizou o pagamento. Você pode escolher outra forma de pagamento ou entrar em contato com o atendimento ao cliente de seu cartão."],
        ["1013", "Sua operadora do cartão de crédito não autorizou o pagamento. Você pode escolher outra forma de pagamento ou entrar em contato com o atendimento ao cliente de seu cartão."],
        ["1001", "A data de vencimento do seu cartão parece estar incorreta. Verifique se você a digitou corretamente."],
        ["2001", "A data de vencimento do seu cartão parece estar incorreta. Verifique se você a digitou corretamente."],
        ["1025", "Seu cartão de crédito parece estar bloqueado. Você pode escolher outra forma de pagamento ou entrar em contato com o atendimento ao cliente de seu cartão."],
        ["9111", "A operadora do cartão de crédito não está respondendo no momento. Por favor, tente outra forma de pagamento."],
        ["WTF", "Não foi possível processar seu pagamento. Você pode escolher outra forma de pagamento ou pode entrar em contato com nosso suporte ao cliente (no canto inferior esquerdo da sua tela) e informar o código \"WTF\"."]
      ].each do |(code, message)|
        context "when the code is #{code}" do
          let(:error_code) { code }
          it { expect(response.error_description).to eq(message) }
        end
      end

    end
  end
end
