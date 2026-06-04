# frozen_string_literal: true

module OFX
  # Base class for all OFX Kit exceptions. Rescue from this to catch any gem error.
  class Error < StandardError; end
end
