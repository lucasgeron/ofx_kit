# frozen_string_literal: true

module OFX
  # Represents the ledger balance of an account at a specific point in time.
  class Balance < Base::Entity
    attr_accessor :amount, :amount_cents, :posted_at

    wired_by_builder :statement, :account
  end
end
