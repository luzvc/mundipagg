RSpec.describe Mundipagg::Gateway::Client do
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
end
