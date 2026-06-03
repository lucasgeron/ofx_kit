# frozen_string_literal: true

module OFX
  module Errors
    # Raised when an operation requires a single statement but multiple were found.
    class MultipleStatementsError < Error; end
  end
end
