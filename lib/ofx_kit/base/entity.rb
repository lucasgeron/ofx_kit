# frozen_string_literal: true

module OFX
  module Base # :nodoc:
    ##
    # Abstract base for domain objects that support dynamic field mappings
    # and relationship wiring via Base::Builder.
    #
    # Subclasses gain two class-level macros:
    # - .ensure_attribute — dynamically adds +attr_accessor+ for custom mapped fields
    # - .wired_by_builder — declares nil-returning placeholder methods that
    #   Base::Builder#wire_relations overrides per-instance at build time
    class Entity
      ##
      # Ensures the given attribute exists on the class, adding +attr_accessor+ if needed.
      # Called by Base::Builder when applying custom field mappings.
      # +name+ is an attribute name (String or Symbol).
      def self.ensure_attribute(name)
        attr_accessor name.to_sym unless method_defined?(name)
      end

      ##
      # Declares one or more placeholder instance methods that return +nil+.
      # Base::Builder replaces each with a singleton method on the built instance
      # that returns the wired relation.
      # +names+ is an Array of Symbol relation names to declare.
      def self.wired_by_builder(*names)
        names.each { |name| define_method(name) { nil } }
      end
    end
  end
end
