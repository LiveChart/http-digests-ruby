# frozen_string_literal: true

require "net/http"
require "action_dispatch"

RSpec.describe HttpDigestHeader::Verifier do
  let(:wanted_digests_string) { "sha-256;q=1" }
  let(:wanted_digests) { HttpDigestHeader::WantedDigestList.parse(wanted_digests_string) }
  let(:good_digest) { "4QbJwMfmd9fYv/yrO8R/e7rasfTmWgtLQOD4boltHHM=" }
  let(:bad_digest) { "rnKn6WJYLAMkLf/sSwt0aOof8dIAjP9GtCrjN+UXkPg=" }
  subject(:verifier) { described_class.new(wanted_digests) }

  let(:good_digest_string) { "sha-256=#{good_digest}" }
  let(:bad_digest_string) { "sha-256=#{bad_digest}" }
  let(:digest_string) { good_digest_string }
  let(:content) { nil }

  let(:right_content) do
    value = <<~JSON.chomp
      {
        "test": "value"
      }
    JSON
  end

  let(:wrong_content) do
    <<~JSON.chomp
      {
        "test":"value"
      }
    JSON
  end

  describe "#verify!" do
    subject(:result) { verifier.verify!(digest_string, content) }

    context "provided the correct content for the digest" do
      let(:content) { right_content }

      it "does not raise" do
        expect { result }.not_to raise_error
      end

      context "but an incorrect digest header" do
        let(:digest_string) { bad_digest_string }

        it "raises IncorrectDigestError" do
          expect { result }.to raise_error(HttpDigestHeader::Verifier::IncorrectDigestError)
        end
      end

      # Ensuring the verifier handles HttpDigestHeader::Algorithm::IllegalDigestValue correctly
      context "but an invalid digest header" do
        let(:digest_string) { "sha-256=a" }

        it "raises IncorrectDigestError" do
          expect { result }.to raise_error(HttpDigestHeader::Verifier::IncorrectDigestError)
        end
      end

      # Ensuring the verifier handles HttpDigestHeader::Algorithm::IllegalDigestValue correctly
      context "but a digest header with an invalid algorithm" do
        let(:digest_string) { "sha-26=#{good_digest}" }

        it "raises IncorrectDigestError" do
          expect { result }.to raise_error(HttpDigestHeader::Verifier::IncorrectDigestError)
        end
      end
    end

    context "provided incorrect content for the digest" do
      let(:content) { wrong_content }

      it "raises IncorrectDigestError" do
        expect { result }.to raise_error(HttpDigestHeader::Verifier::IncorrectDigestError)
      end
    end
  end
end
