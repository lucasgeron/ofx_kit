# frozen_string_literal: true

require 'yaml'

module OFX
  # Manages XML-to-Ruby field mappings used during OFX document parsing.
  #
  # Mappings are split into two layers:
  # - *Core* ({core_mappings.yml}): OFX-standard fields whose Ruby attribute names are
  #   referenced by name inside {Base::Builder}. These cannot be overridden.
  # - *User* ({field_mappings.yml}): convenience mappings that can be added to or replaced
  #   at runtime via {#load_mappings} or the {OFX.configure} block.
  class Configuration
    CORE_MAPPINGS_PATH = File.join(__dir__, '..', 'mappings', 'core_mappings.yml')
    MAPPINGS_PATH      = File.join(__dir__, '..', 'mappings', 'field_mappings.yml')

    # Conventional path for user mappings in a Rails application.
    # Auto-loaded on boot when present. Ejected via +rails generate ofx:eject+.
    RAILS_MAPPINGS_PATH = 'config/initializers/ofx_mappings.yml'

    attr_writer :multi_statement_warnings
    attr_accessor :default_currency

    def multi_statement_warnings?
      @multi_statement_warnings
    end

    def initialize(auto_load_path: File.expand_path(RAILS_MAPPINGS_PATH))
      @multi_statement_warnings = true
      @default_currency = 'USD'

      core = YAML.safe_load_file(CORE_MAPPINGS_PATH)
      @sections = core.fetch('SECTIONS', {})
      @core_fields = core.fetch('FIELDS', {})
      @section_to_tag = @sections.invert

      user = YAML.safe_load_file(MAPPINGS_PATH)
      @user_fields = user.fetch('FIELDS', {})

      load_mappings(auto_load_path) if File.exist?(auto_load_path)
    end

    # Returns a {SectionProxy} for the given section, allowing inline mapping
    # configuration via {SectionProxy#map}.
    %w[bank_statement credit_card_statement transaction bank_account credit_card_account balance].each do |section|
      define_method(section) { SectionProxy.new(@user_fields, @core_fields, xml_tag_for(section)) }
    end

    # Returns the OFX XML tag name corresponding to the given section identifier.
    # @param section_name [String, Symbol] section identifier (e.g. +:transaction+)
    # @return [String, nil] the XML tag name, or +nil+ if not found
    def xml_tag_for(section_name)
      @section_to_tag[section_name.to_s]
    end

    # Returns the merged hash of XML tag → Ruby attribute mappings for the given section.
    # Core mappings take precedence; user mappings extend them.
    # @param section_name [String, Symbol] section identifier
    # @return [Hash{String => String}] mapping of XML tags to Ruby attribute names
    def xml_mappings_for(section_name)
      tag = xml_tag_for(section_name)
      return {} unless tag

      (@core_fields[tag] || {}).merge(@user_fields[tag] || {})
    end

    # Merges additional field mappings from a YAML file into the user-layer configuration.
    # The file must have a top-level +FIELDS+ key. Core OFX fields cannot be overridden.
    # @param path [String] path to the YAML mappings file
    # @raise [ConfigurationError] if the file is missing, malformed, references unknown
    #   sections, or attempts to override a core field mapping
    def load_mappings(path)
      raise ConfigurationError, "Mappings file not found: #{path}" unless File.exist?(path)

      raw = YAML.safe_load_file(path)
      raise ConfigurationError, 'Invalid mappings file: expected a Hash' unless raw.is_a?(Hash)

      fields = raw.fetch('FIELDS') do
        raise ConfigurationError, "Invalid mappings file: missing top-level 'FIELDS' key"
      end

      fields.each { |tag, mappings| merge_user_section(tag, mappings) }
    end

    private

    def merge_user_section(xml_tag, mappings)
      unless @sections.key?(xml_tag.to_s)
        raise ConfigurationError, "Unknown section '#{xml_tag}'. Valid sections: #{@sections.keys.join(', ')}"
      end

      unless mappings.is_a?(Hash)
        raise ConfigurationError, "Mapping value for '#{xml_tag}' must be a Hash, got #{mappings.class}"
      end

      mappings.each_key { |k| assert_not_core!(xml_tag, k) }

      @user_fields[xml_tag.to_s] ||= {}
      @user_fields[xml_tag.to_s].merge!(mappings)
    end

    def assert_not_core!(xml_tag, xml_key)
      core_attr = @core_fields.dig(xml_tag.to_s, xml_key.to_s)
      return unless core_attr

      raise ConfigurationError,
            "Cannot override core mapping '#{xml_tag}.#{xml_key}' (reserved as '#{core_attr}')"
    end
  end
end
