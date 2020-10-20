# frozen_string_literal: true

RSpec.describe HttpDigestHeader::DigestList do
  let(:field_value) { "sha-256=4REjxQ4yrqUVicfSKYNO/cF9zNj5ANbzgDZt3/h3Qxo=,id-sha-256=X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=" }
  let(:parsed) { described_class.parse(field_value) }

  describe ".parse" do
    it "returns the correct object type" do
      expect(parsed).to be_a described_class
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
      expected = HttpDigestHeader::Digest.new(
        "sha-256",
        "4REjxQ4yrqUVicfSKYNO/cF9zNj5ANbzgDZt3/h3Qxo="
      )

      expect(parsed["sha-256"]).to eq(expected)
    end

    it "returns nil for a missing digest" do
      expect(parsed["sha-26"]).to eq(nil)
    end
  end

  describe "#add" do
    let(:list) { described_class.new }
    let(:new_digest) do
      HttpDigestHeader::Digest.new(
        "sha-256",
        "4REjxQ4yrqUVicfSKYNO/cF9zNj5ANbzgDZt3/h3Qxo="
      )
    end

    it "correctly adds a Digest object" do
      expect(list["sha-256"]).to eq(nil)
      list.add(new_digest)
      expect(list["sha-256"]).to eq(new_digest)
    end

    it "correctly adds digest provided an algorithm name and digest value" do
      expect(list["sha-256"]).to eq(nil)
      list.add("sha-256", "4REjxQ4yrqUVicfSKYNO/cF9zNj5ANbzgDZt3/h3Qxo=")
      expect(list["sha-256"]).to eq(new_digest)
    end

    it "raises when adding a duplicate digest" do
      list.add(new_digest)
      expect { list.add(new_digest) }.to raise_error(HttpDigestHeader::Algorithm::DuplicateAlgorithmError)
    end
  end
end
