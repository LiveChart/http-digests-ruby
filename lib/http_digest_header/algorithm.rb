# frozen_string_literal: true

module HttpDigestHeader
  module Algorithm
    class Error < HttpDigestHeader::Error; end
    class IllegalDigestValueError < Error; end

    class DuplicateAlgorithmError < Error
      def initialize(algorithm_name)
        super("Duplicate algorithm: #{algorithm_name}")
      end
    end

    class UnsupportedAlgorithmError < Error
      def initialize(name)
        super("Unsupported algorithm: #{name}")
      end
    end

    # 'id-' prefix explanation:
    #    https://datatracker.ietf.org/doc/draft-polli-id-digest-algorithms/
    # TLDR: 'id-' prefix algorithms are based on the raw (possibly compressed) received content instead of the 'true' content.

    # Not implemented
    # UNIXSUM = "unixsum"
    # UNIXCKSUM = "unixcksum"

    class << self
      def create(name)
        case name
          when IdSha256.name then IdSha256.new
          when IdSha512.name then IdSha512.new
          when Sha256.name then Sha256.new
          when Sha512.name then Sha512.new
          else raise UnsupportedAlgorithmError, name
        end
      end

      def wrap(value)
        case value
        when String
          create(value)
        when Algorithm::Base
          value
        else
          raise ArgumentError, "Invalid algorithm: #{value}"
        end
      end
    end
  end
end
