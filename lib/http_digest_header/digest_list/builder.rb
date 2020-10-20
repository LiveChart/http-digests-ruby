# frozen_string_literal: true

module HttpDigestHeader
  class DigestList
    class Builder
      def initialize
        @value_map = {}
      end

      def add(*args)
        case args.size
        when 1
          arg = args.first

          case arg
            when Digest then add_internal(arg)
            when String then add_internal(Digest.parse(arg))
            else raise ArgumentError, "Must be provided a Digest or encoded digest 'sha-256={base64digest}'"
          end
        when 2
          algorithm, digest = args
          add_internal(Digest.new(algorithm, digest))
        else
          raise ArgumentError, "Invalid arguments"
        end
      end

      def build
        DigestList.new(@value_map)
      end

      def contains?(algorithm_name)
        @value_map.key?(algorithm_name)
      end

      private

      def add_internal(digest)
        algorithm_name = digest.algorithm.name

        if contains?(algorithm_name)
          raise Algorithm::DuplicateAlgorithmError, algorithm_name
        end

        @value_map[algorithm_name] = digest
      end
    end
  end
end
