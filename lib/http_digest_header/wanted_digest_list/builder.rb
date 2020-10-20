# frozen_string_literal: true

module HttpDigestHeader
  class WantedDigestList
    class Builder
      def initialize
        @value_map = {}
      end

      def add(*args)
        case args.size
        when 1
          arg = args.first
          case arg
            when WantedDigest then add_internal(arg)
            when Algorithm::Base then add_internal(WantedDigest.new(arg))
            when String then add_internal(WantedDigest.parse(arg))
            else raise ArgumentError, "Must be provided an algorithm name (e.g. 'sha-512') or encoded wanted digest 'sha-512;q=1'"
          end
        when 2
          algorithm, qvalue = args
          add_internal(WantedDigest.new(algorithm, qvalue: qvalue))
        else
          raise ArgumentError, "Invalid arguments"
        end
      end

      def build
        WantedDigestList.new(@value_map)
      end

      def contains?(algorithm_name)
        @value_map.key?(algorithm_name)
      end

      private

      def add_internal(wanted_digest)
        algorithm_name = wanted_digest.algorithm.name

        if contains?(algorithm_name)
          raise Algorithm::DuplicateAlgorithmError, algorithm_name
        end

        @value_map[algorithm_name] = wanted_digest
      end
    end
  end
end
