# frozen_string_literal: true

module OFX
  # Represents a credit card account parsed from an OFX statement.
  #
  # === Example
  #
  #   account = OFX.new("credit_card.ofx").account
  #   account.account_id   #=> "4111111111111111"
  #   account.currency     #=> "USD"
  #   account.balance      #=> #<OFX::Balance ...>
  #   account.transactions #=> #<OFX::TransactionCollection ...>
  class CreditCardAccount < Base::Account
    # Credit card account number (String).
    attr_accessor :account_id
  end
end
