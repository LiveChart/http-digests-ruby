# frozen_string_literal: true

RSpec.describe HttpDigestHeader::Digest do
  let(:algorithm_name) { "sha-256" }
  let(:digest) { "4REjxQ4yrqUVicfSKYNO/cF9zNj5ANbzgDZt3/h3Qxo=" }
  let(:string_value) { "#{algorithm_name}=#{digest}" }

  describe "initialization" do
    subject(:instance) { described_class.new(algorithm_arg, digest_arg) }

    let(:algorithm_arg) { algorithm_name }
    let(:digest_arg) { digest }

    it "correctly sets the digest" do
      expect(instance.value).to eq(digest)
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
  end

  describe "#same_content?" do
    let(:digest) { described_class.new("sha-256", "X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=") }
    let(:content_value) { '{"hello": "world"}' }

    {
      "X48E9qOokqqrvdts8nOJRJN3OWDUoyWxBf7kbu9DBPE=" => '{"hello": "world"}',
      "47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=" => ""
    }.each do |digest_value, content_value|
      it "correctly verifies the same content" do
        expect(described_class.new("sha-256", digest_value).same_content?(content_value)).to eq(true)
      end
    end

    it "correctly validates different content" do
      expect(digest.same_content?('{"hello":"world"}')).to eq(false)
    end
  end

  describe ".parse" do
    subject(:parsed) { described_class.parse(string_value) }

    it "correctly parses a valid value" do
      expect(parsed).to eq(described_class.new(algorithm_name, digest))
    end

    context "provided an invalid algorithm" do
      let(:algorithm_name) { "sha-26" }

      it "raises the correct error" do
        expect { parsed }.to raise_error(HttpDigestHeader::Algorithm::UnsupportedAlgorithmError)
      end
    end

    context "provided an invalid digest" do
      let(:digest) { "b64" }

      it "raises the correct error" do
        expect { parsed }.to raise_error(HttpDigestHeader::Algorithm::IllegalDigestValueError)
      end
    end
  end

  describe "#to_s" do
    it "produces the correct value" do
      expect(described_class.parse(string_value).to_s).to eq(string_value)
    end
  end

  describe "equality" do
    it "is equal to a different instance with the same attributes" do
      a = described_class.new(algorithm_name, digest)
      b = described_class.new(algorithm_name, digest)
      expect(a).not_to equal(b)
      expect(a).to eq(b)
    end

    it "is not equal to an instance with different attributes" do
      a = described_class.new(algorithm_name, digest)
      b = described_class.new(algorithm_name, "4eEjxQ4yrqUVicfSKYNO/cF9zNj5ANbzgDZt3/h3Qxo=")
      expect(a).not_to eq(b)
    end
  end
end
