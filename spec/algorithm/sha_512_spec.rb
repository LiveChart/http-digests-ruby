# frozen_string_literal: true

RSpec.describe HttpDigestHeader::Algorithm::Sha512 do
  include_context "algorithm context"
  include_examples "algorithm examples",
                   name: "sha-512",
                   digest_class: ::Digest::SHA512,
                   digest_length: 64,
                   padded_base64_length: 88,
                   unpadded_base64_length: 86
end
