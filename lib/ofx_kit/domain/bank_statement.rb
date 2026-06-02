# frozen_string_literal: true

module OFX
  # Represents a complete bank statement parsed from an OFX file,
  # aggregating the account, its transactions, and the closing balance.
  class BankStatement < Base::Statement
    def bank_statement? = true
  end
end
