# frozen_string_literal: true

module OFX
  # An +Enumerable+ collection of {Transaction} objects parsed from an OFX statement.
  # Provides convenience filters for credits and debits.
  class TransactionCollection
    include Enumerable

    # Placeholder overridden per-instance by {Base::Builder#wire} at build time.
    def statement = nil

    # @param transactions [Array<Transaction>] the list of transactions
    def initialize(transactions)
      @transactions = transactions
    end

    # Iterates over each transaction.
    # @yieldparam transaction [Transaction]
    def each(&)
      @transactions.each(&)
    end

    # @return [Integer] number of transactions in the collection
    def length
      @transactions.length
    end

    # @return [TransactionCollection] a new collection containing only positive-amount transactions
    def credits
      sub = self.class.new(select { |t| t.amount.positive? })
      # Propagate statement wiring so inferred_currency resolves to the correct
      # account currency even when this sub-collection has no transactions.
      if (stmt = statement)
        sub.define_singleton_method(:statement) { stmt }
      end
      sub
    end

    # @return [TransactionCollection] a new collection containing only negative-amount transactions
    def debits
      sub = self.class.new(select { |t| t.amount.negative? })
      # Same as credits — statement is the authoritative source of currency.
      if (stmt = statement)
        sub.define_singleton_method(:statement) { stmt }
      end
      sub
    end

    # @return [Money] sum of all positive transaction amounts
    def total_credits
      sum_amounts(credits)
    end

    # @return [Money] sum of all negative transaction amounts
    def total_debits
      sum_amounts(debits)
    end

    # @return [Money] net amount (credits + debits)
    # @note This is NOT the account balance. It reflects only the transactions present in
    #   the OFX file and ignores any accumulated prior balance (e.g. opening cash balance
    #   or unpaid invoice from a previous period). Use {Balance} for the actual account balance.
    def net
      total_credits + total_debits
    end

    # @return [Array<Transaction>] a duplicate of the internal transactions array
    def to_a
      @transactions.dup
    end

    # @param other [TransactionCollection] collection to compare against
    # @return [Boolean]
    def ==(other)
      @transactions == other.to_a
    end

    private

    def currency
      statement&.account&.currency
    end

    def inferred_currency
      currency || OFX.config.default_currency
    end

    def sum_amounts(collection)
      return Money.new(0, inferred_currency) if collection.none?

      collection.map(&:amount).inject(:+)
    end
  end
end
