# frozen_string_literal: true

module OFX
  module Base
    # Base class for OFX statement types, aggregating an account,
    # its transactions, and the closing balance.
    class Statement
      attr_accessor :account, :transactions, :balance

      def initialize(account:, transactions:, balance:)
        @account      = account
        @transactions = transactions
        @balance      = balance
      end

      def bank_statement?        = false
      def credit_card_statement? = false
    end
  end
end
