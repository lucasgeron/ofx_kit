# frozen_string_literal: true

module OFX
  module Errors
    # Raised when the OFX file body cannot be parsed into a valid document.
    class InvalidBodyError < ParseError; end
  end
end
