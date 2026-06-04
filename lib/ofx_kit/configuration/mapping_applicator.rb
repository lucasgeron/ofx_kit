# frozen_string_literal: true

module OFX
  class Configuration
    # Mixin included by Base::Builder to apply Configuration field mappings
    # from an XML node onto a domain object. Reads XML text values, ensures
    # custom attributes exist via Base::Entity.ensure_attribute, and assigns them.
    module MappingApplicator
      private

      def apply_mappings(object, node, section)
        return unless node

        OFX.config.xml_mappings_for(section).each do |xml_tag, ruby_attr|
          value = text_at(node, xml_tag)
          next if value.nil? || value.empty?

          object.class.ensure_attribute(ruby_attr) if object.class.respond_to?(:ensure_attribute)
          object.public_send(:"#{ruby_attr}=", value)
        end
      end

      def currency_for(node, section)
        xml_tag = OFX.config.xml_mappings_for(section).key('currency')
        value = xml_tag && text_at(node, xml_tag)
        raise OFX::Error::InvalidBody, 'Missing required CURDEF tag' if value.nil? || value.empty?

        value
      end

      def text_at(node, css_tag)
        node.at_css(css_tag)&.text&.strip
      end
    end
  end
end
