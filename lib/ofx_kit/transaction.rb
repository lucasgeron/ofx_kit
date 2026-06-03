# frozen_string_literal: true

module OFX
  # Represents a single financial transaction parsed from an OFX statement.
  #
  # === Example
  #
  #   txn = OFX.new("statement.ofx").transactions.first
  #   txn.type         #=> "DEBIT"
  #   txn.name         #=> "AMAZON.COM"
  #   txn.amount       #=> #<Money fractional:-5099 currency:USD>
  #   txn.posted_at    #=> 2024-01-15 00:00:00 +0000
  #   txn.account      #=> #<OFX::BankAccount ...>
  #   txn.statement    #=> #<OFX::BankStatement ...>
  class Transaction < Base::Entity
    # Unique transaction identifier / FITID (String).
    attr_accessor :fit_id
    # Transaction type, e.g. "DEBIT", "CREDIT", "CHECK" (String).
    attr_accessor :type
    # Date the transaction was posted (Time or +nil+).
    attr_accessor :posted_at
    # Date the transaction actually occurred (Time or +nil+).
    attr_accessor :occurred_at
    # Transaction amount as a Money object (or +nil+).
    attr_accessor :amount
    # Transaction amount in the smallest currency unit, e.g. cents (Integer or +nil+).
    attr_accessor :amount_cents
    # Payee or description name (String or +nil+).
    attr_accessor :name
    # Memo or additional description (String or +nil+).
    attr_accessor :memo
    # Payee name from the PAYEE field, when present (String or +nil+).
    attr_accessor :payee
    # Check number, if applicable (String or +nil+).
    attr_accessor :check_number
    # Reference number (String or +nil+).
    attr_accessor :ref_number
    # Standard industry code / SIC (String or +nil+).
    attr_accessor :sic

    # The statement (BankStatement or CreditCardStatement) and account
    # (BankAccount or CreditCardAccount) this transaction belongs to.
    wired_by_builder :statement, :account
  end
end
