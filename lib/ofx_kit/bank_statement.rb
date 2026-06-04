# frozen_string_literal: true

module OFX
  # Represents a complete bank statement parsed from an OFX file,
  # aggregating the account, its transactions, and the closing balance.
  #
  # === Example
  #
  #   stmt = OFX.new("bank.ofx").statements.first
  #   stmt.account              #=> #<OFX::BankAccount ...>
  #   stmt.balance              #=> #<OFX::Balance ...>
  #   stmt.transactions         #=> #<OFX::TransactionCollection ...>
  #   stmt.bank_statement?      #=> true
  class BankStatement < Base::Statement
    # Always +true+.
    def bank_statement? = true
  end
end
