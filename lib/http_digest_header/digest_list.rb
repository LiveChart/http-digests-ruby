# frozen_string_literal: true

module HttpDigestHeader
  class DigestList
    LIST_SEPARATOR = ","

    extend ::Forwardable

    class << self
      def parse(string)
        build do |builder|
          string.split(LIST_SEPARATOR).each { |item| builder.add(item) }
        end
      end

      def build(&block)
        builder = Builder.new
        yield(builder)
        builder.build
      end
    end

    def initialize(value_map)
      @value_map = value_map
    end

    def to_s
      values.map(&:to_s).join(LIST_SEPARATOR)
    end

    def [](algorithm)
      @value_map[algorithm]
    end

    def contains?(algorithm)
      @value_map.key?(algorithm)
    end

    def_delegator :@value_map, :values
    def_delegator :values, :each
  end
end
