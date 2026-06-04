# frozen_string_literal: true

module OFX
  # Represents a complete credit card statement parsed from an OFX file,
  # aggregating the account, its transactions, and the closing balance.
  #
  # === Example
  #
  #   stmt = OFX.new("credit_card.ofx").statements.first
  #   stmt.account                  #=> #<OFX::CreditCardAccount ...>
  #   stmt.balance                  #=> #<OFX::Balance ...>
  #   stmt.transactions             #=> #<OFX::TransactionCollection ...>
  #   stmt.credit_card_statement?   #=> true
  class CreditCardStatement < Base::Statement
    # Always +true+.
    def credit_card_statement? = true
  end
end
