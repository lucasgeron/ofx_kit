# frozen_string_literal: true

module OFX
  # Represents the ledger balance of an account at a specific point in time.
  #
  # === Example
  #
  #   bal = OFX.new("statement.ofx").balance
  #   bal.amount.format  #=> "$2,500.00"
  #   bal.amount_cents   #=> 250000
  #   bal.posted_at      #=> 2024-01-31 00:00:00 +0000
  #   bal.account        #=> #<OFX::BankAccount ...>
  class Balance < Base::Entity
    # Closing balance as a Money object (or +nil+).
    attr_accessor :amount
    # Closing balance in the smallest currency unit, e.g. cents (Integer or +nil+).
    attr_accessor :amount_cents
    # Date the balance was posted (Time or +nil+).
    attr_accessor :posted_at

    # The statement (BankStatement or CreditCardStatement) and account
    # (BankAccount or CreditCardAccount) this balance belongs to.
    wired_by_builder :statement, :account
  end
end
