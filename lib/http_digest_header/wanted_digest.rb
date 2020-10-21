# frozen_string_literal: true

module HttpDigestHeader
  class WantedDigest
    include ::Comparable

    SEPARATOR = ";"
    QVALUE_SEPARATOR = "="
    MIN_QVALUE = 0.0
    MAX_QVALUE = 1.0
    DEFAULT_QVALUE = MAX_QVALUE
    QVALUE_RANGE = MIN_QVALUE..MAX_QVALUE

    QVALUE_REGEX = %r{\Aq=\d(?:\.\d)?\z}

    class Error < HttpDigestHeader::Error; end
    class ParseError < Error; end
    class QvalueRangeError < Error; end

    class << self
      def parse(value)
        algorithm_name, raw_qvalue = value.split(SEPARATOR, 2)
        qvalue = nil

        if raw_qvalue
          if !raw_qvalue.match?(QVALUE_REGEX)
            raise ParseError, "Invalid qvalue: #{raw_qvalue}"
          end

          qvalue = raw_qvalue.split(QVALUE_SEPARATOR, 2).last.to_f
        end

        new(algorithm_name, qvalue: qvalue)
      end
    end

    attr_reader :algorithm, :qvalue

    def initialize(algorithm, qvalue: nil)
      if qvalue && !QVALUE_RANGE.cover?(qvalue)
        raise QvalueRangeError, "Invalid qvalue: #{qvalue} (must be between #{QVALUE_RANGE.min} and #{QVALUE_RANGE.max})"
      end

      @algorithm = Algorithm.wrap(algorithm)
      @qvalue = qvalue&.truncate(1) || DEFAULT_QVALUE
      @qvalue_specified = !qvalue.nil?
    end

    def to_s
      if qvalue_specified?
        "%s%sq=%s" % [algorithm.name, SEPARATOR, qvalue]
      else
        algorithm.name
      end
    end

    def qvalue_specified?
      @qvalue_specified
    end

    def <=>(other)
      qvalue <=> other.qvalue
    end

    def ==(other)
      algorithm.name == other.algorithm.name && qvalue == other.qvalue
    end
  end
end