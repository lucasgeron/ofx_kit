# frozen_string_literal: true

require 'nokogiri'
require 'money'
Money.rounding_mode  = BigDecimal::ROUND_HALF_UP
Money.locale_backend = :currency
require 'stringio'
require 'time'

require_relative 'ofx_kit/version'
require_relative 'ofx_kit/errors/error'
require_relative 'ofx_kit/errors/parse_error'
require_relative 'ofx_kit/errors/invalid_header_error'
require_relative 'ofx_kit/errors/invalid_body_error'
require_relative 'ofx_kit/errors/unsupported_version_error'
require_relative 'ofx_kit/errors/encoding_error'
require_relative 'ofx_kit/errors/configuration_error'
require_relative 'ofx_kit/errors/multiple_statements_error'
require_relative 'ofx_kit/configuration/core'
require_relative 'ofx_kit/configuration/section_proxy'
require_relative 'ofx_kit/configuration/date_parser'
require_relative 'ofx_kit/configuration/mapping_applicator'
require_relative 'ofx_kit/base/entity'
require_relative 'ofx_kit/base/account'
require_relative 'ofx_kit/base/statement'
require_relative 'ofx_kit/base/document'
require_relative 'ofx_kit/bank_account'
require_relative 'ofx_kit/credit_card_account'
require_relative 'ofx_kit/transaction'
require_relative 'ofx_kit/transaction_collection'
require_relative 'ofx_kit/balance'
require_relative 'ofx_kit/bank_statement'
require_relative 'ofx_kit/credit_card_statement'
require_relative 'ofx_kit/base/builder'
require_relative 'ofx_kit/tokenizer/base'
require_relative 'ofx_kit/tokenizer/ofx1'
require_relative 'ofx_kit/tokenizer/ofx2'
require_relative 'ofx_kit/parser'

##
# Top-level namespace for the ofx_kit gem.
# Provides module-level access to the shared Configuration instance and
# a configure block for customizing field mappings and XML tags.
#
# === Example: Configure custom field mappings
#
#   OFX.configure do |config|
#     config.transaction.map 'MYFIELD', to: :my_attribute
#   end
module OFX
  class << self
    ##
    # Parses an OFX file or IO object and returns a Parser instance.
    # This is the primary entry point for the gem.
    # +resource+ is a file path (String) or IO object containing OFX data.
    #
    # === Example: Parse a file path
    #
    #   ofx = OFX.new("statement.ofx")
    #   ofx.account       #=> OFX::BankAccount
    #   ofx.transactions  #=> OFX::TransactionCollection
    #
    # === Example: Parse an IO object
    #
    #   ofx = OFX.new(File.open("statement.ofx"))
    #
    # === Example: Block form
    #
    #   OFX.new("statement.ofx") do |ofx|
    #     puts ofx.balance
    #   end
    def new(resource, &)
      Parser.new(resource, &)
    end

    ##
    # Yields the current Configuration instance for customization.
    #
    # :yields: config
    #
    # Raises Errors::ConfigurationError if the block raises any error.
    def configure
      yield config
    rescue Errors::ConfigurationError
      raise
    rescue StandardError => e
      raise Errors::ConfigurationError, e.message
    end

    ##
    # Returns the shared configuration instance (lazy-initialized).
    def config
      @config ||= Configuration.new
    end

    ##
    # Resets the configuration to its default state.
    # Useful in tests to restore default field mappings between examples.
    def reset_config!
      @config = nil
    end
  end
end
