# frozen_string_literal: true

module HttpDigestHeader
  module Algorithm
    class Sha512 < Base
      self.name = "sha-512"
      self.digest_class = ::Digest::SHA512
      self.digest_length = 64
    end
  end
end
