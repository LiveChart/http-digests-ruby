# frozen_string_literal: true

RSpec.describe HttpDigestHeader::DigestList do
  let(:field_value) { "sha-256=4REjxQ4yrqUVicfSKYNO/cF9zNj5ANbzgDZt3/h3Qxo=,id-sha-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=" }
  let(:parsed) { described_class.parse(field_value) }
  let(:base64_digest_string) { "4REjxQ4yrqUVicfSKYNO/cF9zNj5ANbzgDZt3/h3Qxo=" }

  describe ".parse" do
    it "returns the correct object type" do
      expect(parsed).to be_a described_class
    end

    it "correctly parses" do
      expect(parsed["sha-256"]).to eq(HttpDigestHeader::Digest.new("sha-256", "4REjxQ4yrqUVicfSKYNO/cF9zNj5ANbzgDZt3/h3Qxo="))
      expect(parsed["id-sha-256"]).to eq(HttpDigestHeader::Digest.new("id-sha-256", "X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE="))
    end

    [
      "sha-256=",
      "sha-56=4REjxQ4yrqUVicfSKYNO/cF9zNj5ANbzgDZt3/h3Qxo=",
      "sha-256=test",
    ].each do |invalid_field_value|
      context "given the field value '#{invalid_field_value}'" do
        let(:field_value) { invalid_field_value }

        it "raises" do
          expect { parsed }.to raise_error
        end
      end
    end
  end

  describe ".build" do
    it "passes the build to the provided block" do
      described_class.build do |argument|
        expect(argument).to be_a(HttpDigestHeader::DigestList::Builder)
      end
    end

    it "returns a DigestList" do
      expect(described_class.build { |builder| builder.add("sha-256", base64_digest_string) }).to be_a(described_class)
    end

    it "correctly builds" do
      result = described_class.build do |builder|
        builder.add("sha-256", base64_digest_string)
      end

      expect(result["sha-256"]).to eq(HttpDigestHeader::Digest.new("sha-256", base64_digest_string))
    end
  end

  describe "#contains?" do
    {
      "sha-256" => true,
      "sha-512" => false,
      "id-sha-256" => true,
      "id-sha-512" => false
    }.each do |algorithm_name, expected_value|
      it "correctly identifies the presence of '#{algorithm_name}'" do
        expect(parsed.contains?(algorithm_name)).to eq(expected_value)
      end
    end
  end

  describe "#to_s" do
    it "returns the correct value" do
      expect(parsed.to_s).to eq(field_value)
    end
  end

  describe "#[]" do
    it "correctly fetches an existant digest" do
      expected = HttpDigestHeader::Digest.new("sha-256", base64_digest_string)
      expect(parsed["sha-256"]).to eq(expected)
    end

    it "returns nil for a missing digest" do
      expect(parsed["sha-26"]).to eq(nil)
    end
  end

  %i[<< add remove].each do |method_name|
    it "does not expose a #{method_name} method" do
      expect(parsed).not_to respond_to(method_name)
    end
  end
end
