# frozen_string_literal: true

RSpec.shared_examples "algorithm examples" do |**args|
  it { expect(described_class.name).to eq(args[:name]) }
  it { expect(described_class.digest_class).to eq(args[:digest_class]) }
  it { expect(described_class.digest_length).to eq(args[:digest_length]) }
  it { expect(described_class.padded_base64_digest_length).to eq(args[:padded_base64_length]) }
  it { expect(described_class.unpadded_base64_digest_length).to eq(args[:unpadded_base64_length]) }

  it { expect(instance).to be_a(HttpDigestHeader::Algorithm::Base) }

  describe "#base64digest" do
    it { expect(instance.base64digest("test")).to eq(args[:digest_class].base64digest("test")) }
  end

  describe "#assert_padded_base64_digest_length!" do
    it "does not raise for a valid length value" do
      expect {
        instance.assert_padded_base64_digest_length!("a" * args[:padded_base64_length])
      }.not_to raise_error
    end

    [
      args[:digest_length],
      args[:padded_base64_length] - 1,
      args[:padded_base64_length] + 1,
      args[:unpadded_base64_length]
    ].each do |length|
      it "raises for a value with a length of #{length}" do
        expect {
          instance.assert_padded_base64_digest_length!("a" * length)
        }.to raise_error HttpDigestHeader::Algorithm::IllegalDigestValueError
      end
    end
  end
end
