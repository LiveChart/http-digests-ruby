# frozen_string_literal: true

RSpec.describe HttpDigestHeader::Algorithm::IdSha256 do
  include_context "algorithm context"
  include_examples "algorithm examples",
                   name: "id-sha-256",
                   digest_class: ::Digest::SHA256,
                   digest_length: 32,
                   padded_base64_length: 44,
                   unpadded_base64_length: 43
end
