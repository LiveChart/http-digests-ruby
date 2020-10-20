# frozen_string_literal: true

module HttpDigestHeader
  class Digest
    KEY_VALUE_DELIMITER = "="

    class << self
      def parse(value)
        algorithm_name, digest = value.split(KEY_VALUE_DELIMITER, 2)
        new(algorithm_name, digest)
      end
    end

    attr_reader :algorithm, :value

    def initialize(algorithm, value)
      @algorithm = Algorithm.wrap(algorithm)
      @value = value

      self.algorithm.assert_padded_base64_digest_length!(value)
    end

    def to_s
      "#{algorithm.name}#{KEY_VALUE_DELIMITER}#{value}"
    end

    def same_content?(other_value)
      other_value_digest = algorithm.base64digest(other_value)
      ActiveSupport::SecurityUtils.fixed_length_secure_compare(value, other_value_digest)
    end

    def ==(other)
      algorithm.name == other.algorithm.name && value == other.value
    end
  end
end
