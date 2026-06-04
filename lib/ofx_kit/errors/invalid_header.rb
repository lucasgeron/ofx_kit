# frozen_string_literal: true

module OFX
  class Error
    # Raised when the file header is malformed or missing required fields.
    class InvalidHeader < Parse; end
  end
end
