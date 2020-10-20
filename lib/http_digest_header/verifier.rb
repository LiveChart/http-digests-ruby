# frozen_string_literal: true

module HttpDigestHeader
  class Verifier
    class Error < HttpDigestHeader::Error
      attr_reader :wanted_digests

      def initialize(wanted_digests)
        @wanted_digests = wanted_digests
      end
    end

    class MissingDigestsError < Error; end
    class NoWantedDigestsError < Error; end
    class IncorrectDigestError < Error
      attr_reader :compared_digest

      def initialize(wanted_digests, compared_digest)
        super(wanted_digests)

        @compared_digest = compared_digest
      end
    end

    def initialize(wanted_digests)
      @wanted_digests = wanted_digests
    end

    def verify!(digest_string, content)
      raise_error!(MissingDigestsError) if digest_string.blank?

      digests = DigestList.parse(digest_string)
      most_wanted_digest = @wanted_digests.most_wanted(digests)

      raise_error!(NoWantedDigestsError) if most_wanted_digest.nil?

      return if most_wanted_digest.same_content?(content)

      raise_error!(IncorrectDigestError, most_wanted_digest)
    rescue HttpDigestHeader::Algorithm::Error
      raise_error!(IncorrectDigestError, nil)
    end

    private

    def raise_error!(clazz, *args)
      raise clazz.new(@wanted_digests, *args)
    end
  end
end
