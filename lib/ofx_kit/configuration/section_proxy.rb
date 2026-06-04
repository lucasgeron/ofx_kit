# frozen_string_literal: true

module OFX
  class Configuration
    ##
    # Proxy object returned by section accessors (e.g. +OFX.config.transaction+).
    # Provides a fluent interface for adding individual user-layer field mappings.
    class SectionProxy
      def initialize(user_fields, core_fields, xml_tag)
        @user_fields = user_fields
        @core_fields = core_fields
        @xml_tag     = xml_tag
      end

      ##
      # Maps +xml_key+ (the OFX XML element name, String) to a Ruby attribute name
      # via the +to+ keyword (String or Symbol) for this section.
      #
      # Raises ConfigurationError if +xml_key+ is a core-protected field or has already been mapped.
      #
      # === Example: Map a custom bank-specific field
      #
      #   OFX.configure do |config|
      #     config.transaction.map 'MYFIELD', to: :my_attribute
      #   end
      #   OFX.new("statement.ofx").transactions.first.my_attribute  #=> "custom value"
      def map(xml_key, to:)
        core_attr = @core_fields.dig(@xml_tag.to_s, xml_key.to_s)
        if core_attr
          raise OFX::Error::InvalidConfiguration,
                "Cannot override core mapping '#{@xml_tag}.#{xml_key}' (reserved as '#{core_attr}')"
        end

        @user_fields[@xml_tag] ||= {}

        if @user_fields[@xml_tag].key?(xml_key)
          raise OFX::Error::InvalidConfiguration,
                "Duplicate mapping for '#{@xml_tag}.#{xml_key}' — already mapped to '#{@user_fields[@xml_tag][xml_key]}'"
        end

        @user_fields[@xml_tag][xml_key] = to
      end
    end
  end
end
