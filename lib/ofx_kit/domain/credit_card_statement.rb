# frozen_string_literal: true

module OFX
  # Represents a complete credit card statement parsed from an OFX file,
  # aggregating the account, its transactions, and the closing balance.
  class CreditCardStatement < Base::Statement
    def credit_card_statement? = true
  end
end
