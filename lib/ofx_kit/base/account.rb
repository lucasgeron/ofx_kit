# frozen_string_literal: true

module OFX
  module Base
    # Abstract base class for financial accounts.
    class Account < Entity
      attr_accessor :currency

      wired_by_builder :statement, :balance, :transactions
    end
  end
end
