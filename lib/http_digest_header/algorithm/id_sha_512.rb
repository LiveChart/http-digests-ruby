# frozen_string_literal: true

module HttpDigestHeader
  module Algorithm
    class IdSha512 < Sha512
      self.name = "id-sha-512"
    end
  end
end
