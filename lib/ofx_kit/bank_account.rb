# frozen_string_literal: true

module OFX
  # Represents a bank (checking or savings) account parsed from an OFX statement.
  #
  # === Example
  #
  #   account = OFX.new("bank.ofx").account
  #   account.account_id    #=> "123456789"
  #   account.bank_id       #=> "021000021"
  #   account.account_type  #=> "CHECKING"
  #   account.currency      #=> "USD"
  #   account.balance       #=> #<OFX::Balance ...>
  #   account.transactions  #=> #<OFX::TransactionCollection ...>
  class BankAccount < Base::Account
    # Routing number of the financial institution (String or +nil+).
    attr_accessor :bank_id
    # Account number (String).
    attr_accessor :account_id
    # Account type, e.g. "CHECKING", "SAVINGS" (String or +nil+).
    attr_accessor :account_type
    # Branch identifier, when present (String or +nil+).
    attr_accessor :branch_id
  end
end
