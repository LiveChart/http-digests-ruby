# frozen_string_literal: true

RSpec.describe HttpDigestHeader::WantedDigestList do
  let(:field_value) { "sha-512;q=0.3, sha-256;q=1" }
  let(:parsed) { described_class.parse(field_value) }

  describe ".parse" do
    it "returns the correct object type" do
      expect(parsed).to be_a described_class
    end

    {
      "sha-512; sha-256;" => HttpDigestHeader::WantedDigest::ParseError,
      "sha-256=4REjxQ4yrqUVicfSKYNO/cF9zNj5ANbzgDZt3/h3Qxo=" => HttpDigestHeader::Algorithm::UnsupportedAlgorithmError
    }.each do |invalid_field_value, error_class|
      context "provided the field value '#{invalid_field_value}'" do
        let(:field_value) { invalid_field_value }

        it "raises #{error_class}" do
          expect { parsed }.to raise_error error_class
        end
      end
    end

    it "correctly parses" do
      expect(parsed["sha-512"]).to eq HttpDigestHeader::WantedDigest.new("sha-512", qvalue: 0.3)
      expect(parsed["sha-256"]).to eq HttpDigestHeader::WantedDigest.new("sha-256", qvalue: 1)
    end
  end

  describe ".build" do
    it "passes the build to the provided block" do
      described_class.build do |argument|
        expect(argument).to be_a(HttpDigestHeader::WantedDigestList::Builder)
      end
    end

    it "returns a WantedDigestList" do
      expect(described_class.build { |builder| builder.add("sha-256") }).to be_a(described_class)
    end

    it "correctly builds" do
      result = described_class.build do |builder|
        builder.add("sha-256")
      end

      expect(result["sha-256"]).to eq(HttpDigestHeader::WantedDigest.new("sha-256", qvalue: 1))
    end
  end

  describe "#[]" do
    it "correctly fetches an existant digest" do
      expected = HttpDigestHeader::WantedDigest.new("sha-256", qvalue: 1)
      expect(parsed["sha-256"]).to eq(expected)
    end

    it "returns nil for a missing digest" do
      expect(parsed["sha-26"]).to eq(nil)
    end
  end

  describe "#contains?" do
    {
      "sha-256" => true,
      "sha-512" => true,
      "id-sha-256" => false,
      "id-sha-512" => false
    }.each do |algorithm_name, expected_value|
      it "correctly identifies the presence of '#{algorithm_name}'" do
        expect(parsed.contains?(algorithm_name)).to eq(expected_value)
      end
    end
  end

  describe "#to_a" do
    it "returns the correct value" do
      expect(parsed.to_a).to contain_exactly(
        HttpDigestHeader::WantedDigest.new("sha-512", qvalue: 0.3),
        HttpDigestHeader::WantedDigest.new("sha-256", qvalue: 1)
      )
    end
  end

  describe "#to_s" do
    it "returns the correct value" do
      expect(parsed.to_s).to eq("sha-512;q=0.3, sha-256;q=1.0")
    end
  end

  %i[<< add remove].each do |method_name|
    it "does not expose a #{method_name} method" do
      expect(parsed).not_to respond_to(method_name)
    end
  end
end
