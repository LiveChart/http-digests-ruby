# frozen_string_literal: true

RSpec.describe HttpDigestHeader::Algorithm do
  describe ".create" do
    {
      "sha-256" => HttpDigestHeader::Algorithm::Sha256,
      "sha-512" => HttpDigestHeader::Algorithm::Sha512,
      "id-sha-256" => HttpDigestHeader::Algorithm::IdSha256,
      "id-sha-512" => HttpDigestHeader::Algorithm::IdSha512
    }.each do |name, clazz|
      describe "provided '#{name}'" do
        let(:algorithm) { described_class.create(name) }

        it "returns an instance of #{clazz}" do
          expect(algorithm).to be_a(clazz)
        end

        it "has #name == '#{name}'" do
          expect(algorithm.name).to eq(name)
        end

        it "has #to_s == '#{name}'" do
          expect(algorithm.to_s).to eq(name)
        end
      end
    end

    it "raises error provided an unknown algorithm" do
      expect {
        described_class.create("sha")
      }.to raise_error(HttpDigestHeader::Algorithm::UnsupportedAlgorithmError)
    end
  end

  describe ".wrap" do
    let(:wrap_value) { described_class.wrap(argument) }
    let(:argument) { "sha-256" }

    {
      "sha-256" => HttpDigestHeader::Algorithm::Sha256,
      "sha-512" => HttpDigestHeader::Algorithm::Sha512,
      "id-sha-256" => HttpDigestHeader::Algorithm::IdSha256,
      "id-sha-512" => HttpDigestHeader::Algorithm::IdSha512
    }.each do |name, clazz|
      describe "provided algorithm value #{clazz}" do
        let(:argument) { clazz.new }

        it "returns the same instance" do
          expect(wrap_value).to equal(argument)
        end
      end

      describe "provided string value '#{name}'" do
        let(:argument) { name }

        it "returns an instance of #{clazz}" do
          expect(wrap_value).to be_a(clazz)
        end

        it "has #name == '#{name}'" do
          expect(wrap_value.name).to eq(name)
        end
      end
    end

    it "raises error provided an unknown algorithm string" do
      expect {
        described_class.create("sha")
      }.to raise_error(HttpDigestHeader::Algorithm::UnsupportedAlgorithmError)
    end

    it "raises error provided an unknown object" do
      expect {
        described_class.create(::Digest::SHA256)
      }.to raise_error(HttpDigestHeader::Algorithm::UnsupportedAlgorithmError)
    end

    it "raises error provided a symbol" do
      expect {
        described_class.create(:"sha-256")
      }.to raise_error(HttpDigestHeader::Algorithm::UnsupportedAlgorithmError)
    end
  end
end
