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
      context "given the field value '#{invalid_field_value}'" do
        let(:field_value) { invalid_field_value }

        it "raises #{error_class}" do
          expect { parsed }.to raise_error error_class
        end
      end
    end

    it "correctly parses the wanted digests" do
      expect(parsed["sha-512"]).to eq HttpDigestHeader::WantedDigest.new("sha-512", qvalue: 0.3)
      expect(parsed["sha-256"]).to eq HttpDigestHeader::WantedDigest.new("sha-256", qvalue: 1)
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

  describe "#to_s" do
    it "returns the correct value" do
      expect(parsed.to_s).to eq("sha-512;q=0.3, sha-256;q=1.0")
    end
  end

  describe "#add" do
    let(:list) { described_class.new }
    let(:new_wanted_digest) do
      HttpDigestHeader::WantedDigest.new("sha-256", qvalue: 0.2)
    end

    it "correctly adds a Digest object" do
      expect(list["sha-256"]).to eq(nil)
      list.add(new_wanted_digest)
      expect(list["sha-256"]).to eq(new_wanted_digest)
    end

    it "correctly adds digest provided an algorithm name and digest value" do
      expect(list["sha-256"]).to eq(nil)
      list.add("sha-256", 0.2)
      expect(list["sha-256"]).to eq(new_wanted_digest)
    end

    it "raises when adding a duplicate digest" do
      list.add(new_wanted_digest)
      expect { list.add(new_wanted_digest) }.to raise_error(HttpDigestHeader::Algorithm::DuplicateAlgorithmError)
    end
  end
end
