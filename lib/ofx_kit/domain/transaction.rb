# frozen_string_literal: true

module OFX
  # Represents a single financial transaction parsed from an OFX statement.
  class Transaction < Base::Entity
    attr_accessor :fit_id, :type, :posted_at, :occurred_at,
                  :amount, :amount_cents,
                  :name, :memo, :payee,
                  :check_number, :ref_number, :sic

    wired_by_builder :statement, :account
  end
end
