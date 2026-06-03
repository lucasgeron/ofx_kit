# frozen_string_literal: true

module OFX
  module Base
    # Abstract base class for financial accounts.
    class Account < Entity
      # ISO 4217 currency code, e.g. "USD", "BRL" (String).
      attr_accessor :currency

      # The statement (BankStatement or CreditCardStatement), closing balance (Balance or
      # +nil+), and transactions (TransactionCollection) for this account.
      wired_by_builder :statement, :balance, :transactions
    end
  end
end
