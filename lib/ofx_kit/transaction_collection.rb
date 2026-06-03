# frozen_string_literal: true

module OFX
  ##
  # An +Enumerable+ collection of Transaction objects parsed from an OFX statement.
  # Provides convenience filters for credits and debits.
  class TransactionCollection
    include Enumerable

    ##
    # The statement (BankStatement, CreditCardStatement, or +nil+) this collection belongs to.
    # Overridden per-instance by Base::Builder at build time.
    def statement = nil

    ##
    # Creates a new collection from +transactions+ (Array of Transaction).
    def initialize(transactions)
      @transactions = transactions
    end

    ##
    # Iterates over each transaction.
    #
    # :yields: transaction
    def each(&)
      @transactions.each(&)
    end

    ##
    # Returns the number of transactions in the collection (Integer).
    def length
      @transactions.length
    end

    ##
    # Returns a new TransactionCollection containing only positive-amount transactions.
    #
    # === Example
    #
    #   ofx.transactions.credits.length        #=> 5
    #   ofx.transactions.credits.first.amount  #=> #<Money fractional:10000 currency:USD>
    def credits
      sub = self.class.new(select { |t| t.amount.positive? })
      # Propagate statement wiring so inferred_currency resolves to the correct
      # account currency even when this sub-collection has no transactions.
      if (stmt = statement)
        sub.define_singleton_method(:statement) { stmt }
      end
      sub
    end

    ##
    # Returns a new TransactionCollection containing only negative-amount transactions.
    #
    # === Example
    #
    #   ofx.transactions.debits.length             #=> 37
    #   ofx.transactions.debits.first.name         #=> "AMAZON.COM"
    #   ofx.transactions.debits.first.amount_cents #=> -5099
    def debits
      sub = self.class.new(select { |t| t.amount.negative? })
      # Same as credits — statement is the authoritative source of currency.
      if (stmt = statement)
        sub.define_singleton_method(:statement) { stmt }
      end
      sub
    end

    ##
    # Returns the sum of all positive transaction amounts as a Money object.
    #
    # === Example
    #
    #   ofx.transactions.total_credits.format  #=> "$350.00"
    def total_credits
      sum_amounts(credits)
    end

    ##
    # Returns the sum of all negative transaction amounts as a Money object.
    #
    # === Example
    #
    #   ofx.transactions.total_debits.format  #=> "-$1,234.56"
    def total_debits
      sum_amounts(debits)
    end

    ##
    # Returns the net amount (credits + debits) as a Money object.
    # This is NOT the account balance — it reflects only the transactions present in
    # the OFX file and ignores any accumulated prior balance (e.g. opening cash balance
    # or unpaid invoice from a previous period). Use Balance for the actual account balance.
    #
    # === Example
    #
    #   ofx.transactions.net.format  #=> "$500.00"
    def net
      total_credits + total_debits
    end

    ##
    # Returns a duplicate of the internal transactions array.
    def to_a
      @transactions.dup
    end

    ##
    # Returns +true+ if both collections contain the same transactions as +other+.
    def ==(other)
      @transactions == other.to_a
    end

    private

    def currency
      statement&.account&.currency
    end

    def sum_amounts(collection)
      return Money.new(0, currency) if collection.none?

      collection.map(&:amount).inject(:+)
    end
  end
end
