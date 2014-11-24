RSpec.describe Mundipagg::Gateway::Message do
  describe "#translate" do
    let(:message) { described_class.new({ that_test: { works: "fine" } }) }
    subject { message.translate }

    it { is_expected.to include("mun:ThatTest" => { "mun:Works" => "fine" }) }
  end
end
