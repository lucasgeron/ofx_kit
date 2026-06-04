# frozen_string_literal: true

module OFX
  class Error
    # Raised when a singular helper (e.g. +#account+, +#balance+) is called
    # on a file that contains multiple statements. Use +#accounts+ or +#balances+ instead.
    class MultipleStatements < Error; end
  end
end
