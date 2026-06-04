# frozen_string_literal: true

module OFX
  class Error
    # Raised when the file encoding cannot be handled.
    class UnsupportedEncoding < Error; end
  end
end
