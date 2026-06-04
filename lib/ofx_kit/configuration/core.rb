# frozen_string_literal: true

require 'yaml'

module OFX
  ##
  # Manages XML-to-Ruby field mappings used during OFX document parsing.
  #
  # Mappings are resolved in three layers (last wins):
  # - *Core* (+core_mappings.yml+): OFX-standard fields referenced by name inside
  #   Base::Builder. These cannot be overridden.
  # - *Default* (+field_mappings.yml+): built-in convenience mappings (e.g. FITID → fit_id).
  #   They can be renamed via the OFX.configure block.
  # - *User*: explicit mappings added at runtime via the OFX.configure block.
  class Configuration
    ##
    # Absolute path to the built-in core OFX field mappings (read-only).
    CORE_MAPPINGS_PATH = File.join(__dir__, '..', 'mappings', 'core_mappings.yml')

    ##
    # Absolute path to the built-in default field mappings.
    MAPPINGS_PATH = File.join(__dir__, '..', 'mappings', 'field_mappings.yml')

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
    # Creates a new Configuration instance with the built-in field mappings loaded.
    def initialize
      @multi_statement_warnings = true

      core = YAML.safe_load_file(CORE_MAPPINGS_PATH)
      @sections       = core.fetch('SECTIONS', {})
      @core_fields    = core.fetch('FIELDS', {})
      @section_to_tag = @sections.invert

      defaults = YAML.safe_load_file(MAPPINGS_PATH)
      @default_fields = defaults.fetch('FIELDS', {})

      @user_fields = {}
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
    # Resolution order: core → default → user (user wins).
    def xml_mappings_for(section_name)
      tag = xml_tag_for(section_name)
      return {} unless tag

      (@core_fields[tag] || {})
        .merge(@default_fields[tag] || {})
        .merge(@user_fields[tag] || {})
    end
  end
end
