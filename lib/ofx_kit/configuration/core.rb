# frozen_string_literal: true

require 'yaml'

module OFX
  ##
  # Manages XML-to-Ruby field mappings used during OFX document parsing.
  #
  # Mappings are split into two layers:
  # - *Core* (+core_mappings.yml+): OFX-standard fields whose Ruby attribute names are
  #   referenced by name inside Base::Builder. These cannot be overridden.
  # - *User* (+field_mappings.yml+): convenience mappings that can be added to or replaced
  #   at runtime via #load_mappings or the OFX.configure block.
  class Configuration
    ##
    # Absolute path to the built-in core OFX field mappings (read-only).
    CORE_MAPPINGS_PATH = File.join(__dir__, '..', 'mappings', 'core_mappings.yml')
    ##
    # Absolute path to the built-in user-layer field mappings.
    MAPPINGS_PATH      = File.join(__dir__, '..', 'mappings', 'field_mappings.yml')

    ##
    # Conventional path for user mappings in a Rails application.
    # Auto-loaded on boot when present. Ejected via +rails generate ofx_kit:eject+.
    RAILS_MAPPINGS_PATH = 'config/initializers/ofx_mappings.yml'

    ##
    # Controls whether a warning is emitted when OFX::Parser#transactions or
    # OFX::Parser#balances aggregate across multiple statements.
    # Defaults to +true+.
    attr_writer :multi_statement_warnings

    ##
    # Returns +true+ if multi-statement aggregation warnings are enabled.
    def multi_statement_warnings?
      @multi_statement_warnings
    end

    ##
    # Creates a new Configuration instance.
    # +auto_load_path+ is the path to a YAML mappings file loaded automatically on
    # initialization. Defaults to RAILS_MAPPINGS_PATH expanded from the working directory.
    def initialize(auto_load_path: File.expand_path(RAILS_MAPPINGS_PATH))
      @multi_statement_warnings = true

      core = YAML.safe_load_file(CORE_MAPPINGS_PATH)
      @sections = core.fetch('SECTIONS', {})
      @core_fields = core.fetch('FIELDS', {})
      @section_to_tag = @sections.invert

      user = YAML.safe_load_file(MAPPINGS_PATH)
      @user_fields = user.fetch('FIELDS', {})

      load_mappings(auto_load_path) if File.exist?(auto_load_path)
    end

    ##
    # Returns a SectionProxy for bank statement field mappings.
    def bank_statement        = SectionProxy.new(@user_fields, @core_fields, xml_tag_for(:bank_statement))

    ##
    # Returns a SectionProxy for credit card statement field mappings.
    def credit_card_statement = SectionProxy.new(@user_fields, @core_fields, xml_tag_for(:credit_card_statement))

    ##
    # Returns a SectionProxy for transaction field mappings.
    def transaction           = SectionProxy.new(@user_fields, @core_fields, xml_tag_for(:transaction))

    ##
    # Returns a SectionProxy for bank account field mappings.
    def bank_account          = SectionProxy.new(@user_fields, @core_fields, xml_tag_for(:bank_account))

    ##
    # Returns a SectionProxy for credit card account field mappings.
    def credit_card_account   = SectionProxy.new(@user_fields, @core_fields, xml_tag_for(:credit_card_account))

    ##
    # Returns a SectionProxy for balance field mappings.
    def balance               = SectionProxy.new(@user_fields, @core_fields, xml_tag_for(:balance))

    ##
    # Returns the OFX XML tag name corresponding to the given +section_name+
    # (String or Symbol), e.g. +:transaction+. Returns +nil+ if not found.
    def xml_tag_for(section_name)
      @section_to_tag[section_name.to_s]
    end

    ##
    # Returns the merged Hash of XML tag to Ruby attribute mappings for the given
    # +section_name+ (String or Symbol).
    # Core mappings take precedence; user mappings extend them.
    def xml_mappings_for(section_name)
      tag = xml_tag_for(section_name)
      return {} unless tag

      (@core_fields[tag] || {}).merge(@user_fields[tag] || {})
    end

    ##
    # Merges additional field mappings from a YAML file at +path+ (String)
    # into the user-layer configuration.
    # The file must have a top-level +FIELDS+ key. Core OFX fields cannot be overridden.
    #
    # Raises ConfigurationError if the file is missing, malformed, references
    # unknown sections, or attempts to override a core field mapping.
    #
    # === Example: Load a custom mappings file
    #
    #   OFX.configure do |config|
    #     config.load_mappings 'config/my_ofx_mappings.yml'
    #   end
    #
    # === Example: Expected YAML format
    #
    #   # config/my_ofx_mappings.yml
    #   FIELDS:
    #     STMTTRN:
    #       MYFIELD: my_attribute
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
