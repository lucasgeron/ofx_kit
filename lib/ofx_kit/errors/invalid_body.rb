# frozen_string_literal: true

module OFX
  class Error
    # Raised when the file body is malformed or missing required fields (e.g. CURDEF).
    class InvalidBody < Parse; end
  end
end
