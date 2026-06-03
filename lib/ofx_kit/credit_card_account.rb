# frozen_string_literal: true

module OFX
  # Represents a credit card account parsed from an OFX statement.
  class CreditCardAccount < Base::Account
    # Credit card account number (String).
    attr_accessor :account_id
  end
end
