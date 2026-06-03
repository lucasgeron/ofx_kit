# frozen_string_literal: true

module OFX
  module Errors
    # Raised when a character encoding error occurs while reading the OFX file.
    class EncodingError < Error; end
  end
end
