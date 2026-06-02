# frozen_string_literal: true

module OFX
  # Represents a bank (checking or savings) account parsed from an OFX statement.
  class BankAccount < Base::Account
    attr_accessor :bank_id, :account_id, :account_type, :branch_id
  end
end
