# frozen_string_literal: true

RSpec.describe HttpDigestHeader::WantedDigestList::Builder do
  let(:builder) { described_class.new }
  let(:built) { builder.build }

  describe "initialization" do
    it "does not accept arguments" do
      expect { described_class.new(Hash.new) }.to raise_error ArgumentError
    end
  end

  describe "#build" do
    it "returns a WantedDigestList" do
      expect(built).to be_a(HttpDigestHeader::WantedDigestList)
    end
  end

  describe "#add" do
    it "correctly adds a WantedDigest" do
      expected = HttpDigestHeader::WantedDigest.new("sha-256", qvalue: 0.2)
      builder.add(expected)
      expect(built["sha-256"]).to eq(expected)
    end

    it "correctly adds a wanted digest string" do
      expected = HttpDigestHeader::WantedDigest.new("sha-256", qvalue: 0.2)
      builder.add("sha-256;q=0.2")
      expect(built["sha-256"]).to eq(expected)
    end

    it "correctly adds an algorithm string" do
      expected = HttpDigestHeader::WantedDigest.new("sha-256", qvalue: 1.0)
      builder.add("sha-256")
      expect(built["sha-256"]).to eq(expected)
    end

    it "correctly adds an algorithm" do
      expected = HttpDigestHeader::WantedDigest.new("sha-256", qvalue: 1.0)
      builder.add(expected.algorithm)
      expect(built["sha-256"]).to eq(expected)
    end

    it "raises when provided a duplicate" do
      builder.add("sha-256")
      expect { builder.add("sha-256") }.to raise_error(HttpDigestHeader::Algorithm::DuplicateAlgorithmError)
    end
  end

  describe "#contains?" do
    it "correctly identifies a present value" do
      builder.add("sha-256")
      expect(builder.contains?("sha-256")).to eq(true)
    end

    it "correctly identifies a non present value" do
      builder.add("sha-256")
      expect(builder.contains?("sha-512")).to eq(false)
    end
  end
end
