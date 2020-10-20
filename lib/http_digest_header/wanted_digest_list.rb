# frozen_string_literal: true

module HttpDigestHeader
  class WantedDigestList
    LIST_DELIMITER = ", "

    class << self
      def parse(string)
        new(string.split(LIST_DELIMITER).map! { |item| WantedDigest.parse(item) })
      end
    end

    def initialize(values = nil)
      # The array is used to maintain order.
      @value_map = {}
      @values = []

      values.each { |value| add(value) } if values
    end

    def add(*args)
      case args.size
      when 1
        arg = args.first
        case arg
          when WantedDigest then add_internal(arg)
          when String, Algorithm::Base then add_internal(WantedDigest.new(algorithm: arg))
          else raise ArgumentError, "Must be provided an algorithm or algorithm name"
        end
      when 2
        algorithm, qvalue = args
        add_internal(WantedDigest.new(algorithm, qvalue: qvalue))
      else
        raise ArgumentError, "Invalid arguments"
      end
    end

    def to_s
      @values.map(&:to_s).join(LIST_DELIMITER)
    end

    def [](algorithm)
      @value_map[algorithm]
    end

    def contains?(algorithm_name)
      @value_map.key?(algorithm_name)
    end

    def most_wanted(digest_list)
      most_wanted = nil

      digest_list.each do |digest|
        this_want = self[digest.algorithm.name]

        next if this_want.nil?

        if most_wanted.nil? || this_want > most_wanted
          most_wanted = this_want
        end
      end

      digest_list[most_wanted.algorithm.name] if most_wanted
    end

    private

    def add_internal(wanted_digest)
      algorithm_name = wanted_digest.algorithm.name

      if contains?(algorithm_name)
        raise Algorithm::DuplicateAlgorithmError, algorithm_name
      end

      @value_map[algorithm_name] = wanted_digest
      @values << wanted_digest
    end
  end
end
