# frozen_string_literal: true

module OFX
  class Error
    # Raised when +OFX.configure+ receives an invalid argument.
    class InvalidConfiguration < Error; end
  end
end
