# frozen_string_literal: true

module OFX
  module Errors
    # Raised when the OFX file header is malformed or missing.
    class InvalidHeaderError < ParseError; end
  end
end
