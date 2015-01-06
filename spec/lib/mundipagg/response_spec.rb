require "spec_helper"

RSpec.describe Mundipagg::Response do
  describe "#success?" do
    context "when true" do
      subject { described_class.new success: true }
      it { expect(subject).to be_success }
    end

    context "when false" do
      subject { described_class.new success: false }
      it { expect(subject).to_not be_success }
    end

    context "when nil" do
      it { expect(subject).to_not be_success }
    end
  end

  describe "#error_item" do
    it { expect { subject.error_item }.to raise_error("Not yet implemented") }
  end

  describe "#error" do
    context "when error_item is present" do
      before do
        allow(subject).to receive(:error_item).and_return({ description: "Error", error_code: 0 })
      end

      it { expect(subject.error).to be_a(Mundipagg::Error) }
      it { expect(subject.error.message).to eq("Error") }
      it { expect(subject.error.code).to eq(0) }
    end

    context "when error_item is not present" do
      before do
        allow(subject).to receive(:error_item).and_return(nil)
      end

      it { expect(subject.error).to be_nil }
    end
  end
end
