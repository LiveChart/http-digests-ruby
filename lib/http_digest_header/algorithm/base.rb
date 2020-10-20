# frozen_string_literal: true

module HttpDigestHeader
  module Algorithm
    class Base
      extend ::Forwardable

      class_attribute :name, instance_writer: false, instance_predicate: false
      class_attribute :digest_class, instance_writer: false, instance_predicate: false
      class_attribute :digest_length, instance_writer: false, instance_predicate: false

      def_delegator :digest_class, :base64digest

      class << self
        def padded_base64_digest_length
          4 * ((digest_length + 2) / 3)
        end

        def unpadded_base64_digest_length
          ((4 * digest_length) + 2) / 3
        end
      end

      def assert_padded_base64_digest_length!(value)
        return if value.length == self.class.padded_base64_digest_length
        raise IllegalDigestValueError, "Invalid base64 digest for #{name}: #{value}"
      end
    end
  end
end
