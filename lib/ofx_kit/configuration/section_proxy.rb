# frozen_string_literal: true

module OFX
  class Configuration
    # Proxy object returned by section accessors (e.g. +OFX.config.transaction+).
    # Provides a fluent interface for adding individual user-layer field mappings.
    class SectionProxy
      def initialize(user_fields, core_fields, xml_tag)
        @user_fields = user_fields
        @core_fields = core_fields
        @xml_tag     = xml_tag
      end

      # Maps an OFX XML key to a Ruby attribute name for this section.
      # @param xml_key [String] the OFX XML element name
      # @param to [String, Symbol] the Ruby attribute name to map to
      # @raise [ConfigurationError] if xml_key is a core-protected field
      def map(xml_key, to:)
        core_attr = @core_fields.dig(@xml_tag.to_s, xml_key.to_s)
        if core_attr
          raise OFX::ConfigurationError,
                "Cannot override core mapping '#{@xml_tag}.#{xml_key}' (reserved as '#{core_attr}')"
        end

        @user_fields[@xml_tag] ||= {}
        @user_fields[@xml_tag][xml_key] = to
      end
    end
  end
end
