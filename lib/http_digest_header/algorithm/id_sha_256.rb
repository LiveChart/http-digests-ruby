# frozen_string_literal: true

module HttpDigestHeader
  module Algorithm
    class IdSha256 < Sha256
      self.name = "id-sha-256"
    end
  end
end
