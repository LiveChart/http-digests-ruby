# frozen_string_literal: true

module HttpDigestHeader
  class WantedDigestList
    LIST_SEPARATOR = ", "

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

    def to_a
      @value_map.values
    end

    def to_s
      to_a.map(&:to_s).join(LIST_SEPARATOR)
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
  end
end
