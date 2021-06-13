# frozen_string_literal: true

module Solargraph
  module Pin
    module Localized
      # @return [Range]
      attr_reader :presence

      # @param other [Pin::Base] The caller's block
      # @param position [Position, Array(Integer, Integer)] The caller's position
      # @return [Boolean]
      def visible_from?(other, position)
        position = Position.normalize(position)
        other.filename == filename &&
          match_tags(other.full_context.tag, full_context.tag) &&
          (other == closure ||
            (closure.location.range.contain?(other.location.range.start) && closure.location.range.contain?(other.location.range.ending))
          ) &&
          presence.contain?(position)
      end

      # @param other_loc [Location]
      def visible_at?(other_closure, other_loc)
        return true if location.filename == other_loc.filename &&
          presence.include?(other_loc.range.start) &&
          match_named_closure(other_closure, closure)
      end

      private

      # @param tag1 [String]
      # @param tag2 [String]
      # @return [Boolean]
      def match_tags tag1, tag2
        # @todo This is an unfortunate hack made necessary by a discrepancy in
        #   how tags indicate the root namespace. The long-term solution is to
        #   standardize it, whether it's `Class<>`, an empty string, or
        #   something else.
        tag1 == tag2 ||
          (['', 'Class<>'].include?(tag1) && ['', 'Class<>'].include?(tag2))
      end

      def match_named_closure needle, haystack
        return true if needle == haystack
        cursor = haystack
        until cursor.nil?
          return true if needle.path == cursor.path
          return false if cursor.path && !cursor.path.empty?
          cursor = cursor.closure
        end
        false
      end
    end
  end
end
