# frozen_string_literal: true

module HttpDigestHeader
  class DigestList
    LIST_DELIMITER = ","

    extend ::Forwardable

    class << self
      def parse(string)
        new(string.split(LIST_DELIMITER).map! { |item| Digest.parse(item) })
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
        add_internal(args.first)
      when 2
        algorithm, digest = args
        add_internal(Digest.new(algorithm, digest))
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

    def contains?(algorithm)
      @value_map.key?(algorithm)
    end

    def_delegator :@values, :each

    private

    def add_internal(digest)
      algorithm_name = digest.algorithm.name

      if contains?(algorithm_name)
        raise Algorithm::DuplicateAlgorithmError, algorithm_name
      end

      @value_map[algorithm_name] = digest
      @values << digest
    end
  end
end
