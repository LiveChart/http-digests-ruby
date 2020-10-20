# frozen_string_literal: true

RSpec.describe HttpDigestHeader::DigestList::Builder do
  let(:builder) { described_class.new }
  let(:built) { builder.build }
  let(:digest_string) { "4REjxQ4yrqUVicfSKYNO/cF9zNj5ANbzgDZt3/h3Qxo=" }

  describe "initialization" do
    it "does not accept arguments" do
      expect { described_class.new(Hash.new) }.to raise_error ArgumentError
    end
  end

  describe "#build" do
    it "returns a DigestList" do
      expect(built).to be_a(HttpDigestHeader::DigestList)
    end
  end

  describe "#add" do
    it "correctly adds a Digest" do
      expected = HttpDigestHeader::Digest.new("sha-256", digest_string)
      builder.add(expected)
      expect(built["sha-256"]).to eq(expected)
    end

    it "correctly adds a digest string" do
      expected = HttpDigestHeader::Digest.new("sha-256", digest_string)
      builder.add("sha-256=4REjxQ4yrqUVicfSKYNO/cF9zNj5ANbzgDZt3/h3Qxo=")
      expect(built["sha-256"]).to eq(expected)
    end

    it "correctly adds with an algorithm string and digest" do
      expected = HttpDigestHeader::Digest.new("sha-256", digest_string)
      builder.add("sha-256", digest_string)
      expect(built["sha-256"]).to eq(expected)
    end

    it "correctly adds with an algorithm and digest" do
      expected = HttpDigestHeader::Digest.new("sha-256", digest_string)
      builder.add(expected.algorithm, digest_string)
      expect(built["sha-256"]).to eq(expected)
    end

    it "raises when provided an invalid digest string" do
      expect { builder.add("sha-256") }.to raise_error(HttpDigestHeader::Digest::InvalidValueError)
    end

    it "raises when provided a duplicate" do
      builder.add("sha-256", digest_string)
      expect { builder.add("sha-256", digest_string) }.to raise_error(HttpDigestHeader::Algorithm::DuplicateAlgorithmError)
    end
  end

  describe "#contains?" do
    let(:digest) { HttpDigestHeader::Digest.new("sha-256", digest_string) }

    it "correctly identifies a present value" do
      builder.add(digest)
      expect(builder.contains?("sha-256")).to eq(true)
    end

    it "correctly identifies a non present value" do
      builder.add(digest)
      expect(builder.contains?("sha-512")).to eq(false)
    end
  end
end
