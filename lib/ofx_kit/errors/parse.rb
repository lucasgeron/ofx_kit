# frozen_string_literal: true

module OFX
  class Error
    # Raised when the OFX header or body cannot be parsed.
    class Parse < Error; end
  end
end
