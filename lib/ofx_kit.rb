# frozen_string_literal: true

require 'nokogiri'
require 'money'
Money.rounding_mode  = BigDecimal::ROUND_HALF_UP
Money.locale_backend = :currency
require 'stringio'
require 'time'

require_relative 'ofx_kit/version'
require_relative 'ofx_kit/errors'
require_relative 'ofx_kit/configuration'
require_relative 'ofx_kit/base/entity'
require_relative 'ofx_kit/base/account'
require_relative 'ofx_kit/base/statement'
require_relative 'ofx_kit/base/document'
require_relative 'ofx_kit/domain/bank_account'
require_relative 'ofx_kit/domain/credit_card_account'
require_relative 'ofx_kit/domain/transaction'
require_relative 'ofx_kit/domain/transaction_collection'
require_relative 'ofx_kit/domain/balance'
require_relative 'ofx_kit/domain/bank_statement'
require_relative 'ofx_kit/domain/credit_card_statement'
require_relative 'ofx_kit/base/builder'
require_relative 'ofx_kit/tokenizer/base'
require_relative 'ofx_kit/tokenizer/ofx1'
require_relative 'ofx_kit/tokenizer/ofx2'
require_relative 'ofx_kit/parser'

# Top-level namespace for the ofx_kit gem.
# Provides module-level access to the shared {Configuration} instance and
# a {.configure} block for customizing field mappings and XML tags.
#
# @example Configure custom field mappings
#   OFX.configure do |config|
#     config.transaction.map 'MYFIELD', to: :my_attribute
#   end
module OFX
  class << self
    # Parses an OFX file or IO object and returns a {Parser} instance.
    # This is the primary entry point for the gem.
    #
    # @param resource [String, IO] file path or IO object containing OFX data
    # @return [Parser]
    #
    # @example Parse a file path
    #   ofx = OFX.new("statement.ofx")
    #   ofx.account       #=> OFX::BankAccount
    #   ofx.transactions  #=> OFX::TransactionCollection
    #
    # @example Parse an IO object
    #   ofx = OFX.new(File.open("statement.ofx"))
    #
    # @example Block form
    #   OFX.new("statement.ofx") do |ofx|
    #     puts ofx.balance
    #   end
    def new(resource, &)
      Parser.new(resource, &)
    end

    # Yields the current {Configuration} instance for customization.
    # @yieldparam config [Configuration]
    # @raise [ConfigurationError] if the block raises any error
    def configure
      yield config
    rescue ConfigurationError
      raise
    rescue StandardError => e
      raise ConfigurationError, e.message
    end

    # @return [Configuration] the shared configuration instance (lazy-initialized)
    def config
      @config ||= Configuration.new
    end

    # Resets the configuration to its default state.
    # Useful in tests to restore default field mappings between examples.
    def reset_config!
      @config = nil
    end
  end
end
