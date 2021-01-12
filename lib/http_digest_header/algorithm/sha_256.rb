# frozen_string_literal: true

require "digest"

module HttpDigestHeader
  module Algorithm
    class Sha256 < Base
      self.name = "sha-256"
      self.digest_class = ::Digest::SHA256
      self.digest_length = 32
    end
  end
end
