# frozen_string_literal: true

RSpec.describe HttpDigestHeader::WantedDigest do
  let(:string_value_without_qvalue) { algorithm_name }
  let(:string_value_with_qvalue) { "sha-256;q=0.5" }
  let(:algorithm_name) { "sha-256" }

  describe ".parse" do
    subject(:parsed) { described_class.parse(string_value) }

    {
      "sha-256;q=1" => 1,
      "sha-256;q=0.5" => 0.5
    }.each do |string, qvalue|
      it "correctly parses '#{string}'" do
        expect(described_class.parse(string)).to \
          eq(described_class.new("sha-256", qvalue: qvalue))
      end
    end

    [
      "sha-256 ; q=0.5",
      "sha-256;q= 0.5",
      "sha-256;q =0.5",
      "sha-256;q=0.55",
      "sha-256;q="
    ].each do |string|
      it "raises an error provided '#{string}'" do
        expect { described_class.parse(string) }.to \
          raise_error(HttpDigestHeader::WantedDigest::ParseError)
      end
    end

    [
      "sha-26;q=0.5",
      "sha-26"
    ].each do |string|
      it "raises an error provided '#{string}'" do
        expect { described_class.parse(string) }.to \
          raise_error(HttpDigestHeader::Algorithm::UnsupportedAlgorithmError)
      end
    end

    # it "correctly parses a valid value" do
    #   expect(parsed).to eq(described_class.new(algorithm_name, digest))
    # end

    # context "provided an invalid algorithm" do
    #   let(:algorithm_name) { "sha-26" }

    #   it "raises the correct error" do
    #     expect { parsed }.to raise_error(HttpDigestHeader::UnsupportedAlgorithmError)
    #   end
    # end

    # context "provided an invalid digest" do
    #   let(:digest) { "b64" }

    #   it "raises the correct error" do
    #     expect { parsed }.to raise_error(HttpDigestHeader::IllegalDigestValue)
    #   end
    # end
  end

  describe "initialization" do
    subject(:instance) { described_class.new(algorithm_arg, qvalue: qvalue_arg) }

    let(:algorithm_arg) { algorithm_name }
    let(:qvalue_arg) { nil }

    [
      -0.01,
      1.00001
    ].each do |qvalue|
      it "raises an error provided a qvalue of '#{qvalue}'" do
        expect { described_class.new("sha-256", qvalue: qvalue) }.to \
          raise_error(HttpDigestHeader::WantedDigest::QvalueRangeError)
      end
    end

    context "provided an algorithm name string" do
      it "does not raise an error" do
        expect { instance }.not_to raise_error
      end

      it "correctly sets the algorithm" do
        expect(instance.algorithm.name).to eq("sha-256")
      end
    end

    context "provided an algorithm instance" do
      let(:algorithm_arg) { HttpDigestHeader::Algorithm.wrap(algorithm_name) }

      it "does not raise an error" do
        expect { instance }.not_to raise_error
      end

      it "correctly sets the algorithm" do
        expect(instance.algorithm.name).to eq("sha-256")
      end
    end

    it "truncates the qvalue" do
      expect(described_class.new("sha-256", qvalue: 0.55).qvalue).to eq(0.5)
    end
  end

  describe "#to_s" do
    it { expect(described_class.new("sha-256").to_s).to eq("sha-256") }
    it { expect(described_class.new("sha-256", qvalue: 0.5).to_s).to eq("sha-256;q=0.5") }
    it { expect(described_class.new("sha-256", qvalue: 1).to_s).to eq("sha-256;q=1") }
    it { expect(described_class.new("sha-256", qvalue: 0).to_s).to eq("sha-256;q=0") }
  end

  describe "#qvalue_specified?" do
    it { expect(described_class.new("sha-256").qvalue_specified?).to be false }
    it { expect(described_class.new("sha-256", qvalue: nil).qvalue_specified?).to be false }
    it { expect(described_class.new("sha-256", qvalue: 1.0).qvalue_specified?).to be true }
  end

  describe "equality" do
    [
      ["sha-256", qvalue: 1],
      ["sha-256", qvalue: nil],
      ["sha-256", qvalue: 0.5],
    ].each do |args|
      it "is equal to a different instance with the same attributes (#{args})" do
        a = described_class.new(*args)
        b = described_class.new(*args)
        expect(a).not_to equal(b)
        expect(a).to eq(b)
      end
    end

    it "is not equal to an instance with different attributes" do
      a = described_class.new(algorithm_name)
      b = described_class.new(algorithm_name, qvalue: 0.5)
      expect(a).not_to eq(b)
    end
  end

  describe "comparison" do
    it "correctly compares the default qvalue" do
      a = described_class.new("sha-256")
      b = described_class.new("sha-512", qvalue: 0.5)
      expect(a).to be > b
    end

    it "correctly compares a specified qvalue" do
      a = described_class.new("sha-256", qvalue: 0.4)
      b = described_class.new("sha-512", qvalue: 0.5)
      expect(a).to be < b
    end

    it "correctly compares the same qvalue" do
      a = described_class.new("sha-256")
      b = described_class.new("sha-512", qvalue: 1.0)
      expect(a).not_to be < b
      expect(a).not_to be > b
    end
  end
end
