# frozen_string_literal: true

module OFX
  module Base
    ##
    # Base class for OFX statement types, aggregating an account,
    # its transactions, and the closing balance.
    class Statement
      ##
      # The account associated with this statement (BankAccount or CreditCardAccount).
      attr_accessor :account
      ##
      # The transactions in this statement (TransactionCollection).
      attr_accessor :transactions
      ##
      # The closing balance for this statement (Balance or +nil+).
      attr_accessor :balance

      ##
      # Creates a new statement.
      # +account+ is a BankAccount or CreditCardAccount.
      # +transactions+ is a TransactionCollection.
      # +balance+ is a Balance or +nil+.
      def initialize(account:, transactions:, balance:)
        @account      = account
        @transactions = transactions
        @balance      = balance
      end

      ##
      # Always +false+.
      def bank_statement?        = false
      ##
      # Always +false+.
      def credit_card_statement? = false
    end
  end
end
