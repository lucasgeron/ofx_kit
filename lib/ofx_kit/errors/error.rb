# frozen_string_literal: true

module OFX
  # Namespace for all gem-specific exception classes.
  # All errors inherit from Errors::Error, so callers can rescue the entire hierarchy
  # with <tt>rescue OFX::Errors::Error</tt>.
  module Errors
    # Base error class for all OFX-related exceptions.
    class Error < StandardError; end
  end
end
