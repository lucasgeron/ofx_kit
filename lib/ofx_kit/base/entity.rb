# frozen_string_literal: true

module OFX
  module Base
    # Abstract base for domain objects that support dynamic field mappings
    # and relationship wiring via {Base::Builder}.
    #
    # Subclasses gain two class-level macros:
    # - {.ensure_attribute} — dynamically adds +attr_accessor+ for custom mapped fields
    # - {.wired_by_builder} — declares nil-returning placeholder methods that
    #   {Base::Builder#wire_relations} overrides per-instance at build time
    class Entity
      def self.ensure_attribute(name)
        attr_accessor name.to_sym unless method_defined?(name)
      end

      def self.wired_by_builder(*names)
        names.each { |name| define_method(name) { nil } }
      end
    end
  end
end
