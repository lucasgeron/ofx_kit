# frozen_string_literal: true

module OFX
  ##
  # The object returned by OFX.new. Provides access to the parsed statements,
  # accounts, transactions, and balances from an OFX file or IO object.
  # Prefer the top-level OFX.new entry point over instantiating this class directly.
  class Parser
    ##
    # Parses the given OFX +resource+ and builds the statement graph.
    # +resource+ is a file path (String) or IO object containing OFX data.
    # If a +block+ is given with arity 1, it receives the parser instance;
    # otherwise it is evaluated in the parser's context.
    def initialize(resource, &block)
      @filename   = extract_filename(resource)
      content     = read_resource(resource)
      tokenizer   = build_tokenizer(content).new(content)
      @document   = Base::Document.new(headers: tokenizer.headers, body: tokenizer.body)
      @statements = Base::Builder.new(@document).statements

      return unless block_given?

      block.arity == 1 ? block.call(self) : instance_eval(&block)
    end

    ##
    # All statements in the file (Array of BankStatement or CreditCardStatement).
    #
    # === Example: Iterate statements in a multi-account file
    #
    #   ofx = OFX.new("multi.ofx")
    #   ofx.statements.each do |stmt|
    #     puts "#{stmt.account.account_id}: #{stmt.transactions.length} transactions"
    #   end
    attr_reader :statements

    ##
    # Original file path, if a path string was provided (String or +nil+).
    attr_reader :filename

    ##
    # Returns the parsed OFX header fields (Hash).
    def headers
      @document.headers
    end

    ##
    # Returns the account for files containing a single statement
    # (BankAccount, CreditCardAccount, or +nil+).
    # Raises MultipleStatementsError if the file contains more than one statement.
    #
    # === Example
    #
    #   ofx = OFX.new("statement.ofx")
    #   ofx.account.account_id    #=> "123456789"
    #   ofx.account.currency      #=> "USD"
    #   ofx.account.bank_id       #=> "021000021"   # BankAccount only
    def account
      if statements.length > 1
        raise MultipleStatementsError, 'File contains multiple statements. Use `accounts` to get all accounts.'
      end

      statements.first&.account
    end

    ##
    # Returns all accounts across all statements
    # (Array of BankAccount or CreditCardAccount).
    #
    # === Example: Multi-statement file
    #
    #   ofx = OFX.new("multi.ofx")
    #   ofx.accounts.map(&:account_id)  #=> ["123456", "789012"]
    def accounts
      statements.map(&:account)
    end

    ##
    # Returns all transactions aggregated across all statements as a TransactionCollection.
    # Emits a warning when the file contains multiple statements.
    #
    # === Example
    #
    #   ofx = OFX.new("statement.ofx")
    #   ofx.transactions.length               #=> 42
    #   ofx.transactions.credits.length       #=> 10
    #   ofx.transactions.total_debits.format  #=> "-$1,234.56"
    #   ofx.transactions.net.format           #=> "$500.00"
    def transactions
      if statements.length > 1 && OFX.config.multi_statement_warnings?
        warn "[OFX] `transactions` is aggregating across #{statements.length} statements. " \
             'For per-account transactions use `statements[i].transactions`. ' \
             'To disable this warning: OFX.config.multi_statement_warnings = false'
      end

      TransactionCollection.new(statements.flat_map { |s| s.transactions.to_a })
    end

    ##
    # Returns the balance for files containing a single statement (Balance or +nil+).
    # Raises MultipleStatementsError if the file contains more than one statement.
    #
    # === Example
    #
    #   ofx = OFX.new("statement.ofx")
    #   ofx.balance.amount.format  #=> "$2,500.00"
    #   ofx.balance.amount_cents   #=> 250000
    #   ofx.balance.posted_at      #=> 2024-01-31 00:00:00 +0000
    def balance
      if statements.length > 1
        raise MultipleStatementsError, 'File contains multiple statements. Use `balances` to get all balances.'
      end

      statements.first&.balance
    end

    ##
    # Returns balances for each statement (Array of Balance or +nil+).
    def balances
      if statements.length > 1 && OFX.config.multi_statement_warnings?
        warn "[OFX] `balances` is aggregating across #{statements.length} statements. " \
             'For per-account balance use `statements[i].balance`. ' \
             'To disable this warning: OFX.config.multi_statement_warnings = false'
      end

      statements.map(&:balance)
    end

    ##
    # Returns a structured summary of all statements, including transaction counts,
    # credit/debit totals (in cents), and closing balance.
    #
    # Returns a Hash with keys:
    # - +:headers+ — compact OFX header fields
    # - +:statements+ — hash keyed by account_id, each with:
    #   +:currency+, +:transactions+ ({count:, net_cents:}),
    #   +:credits+ ({count:, total_cents:}), +:debits+ ({count:, total_cents:}),
    #   +:balance_cents+
    def summary
      {
        headers: headers.compact,
        statements: statements.each_with_object({}) do |stmt, h|
          acct = stmt.account
          txns = stmt.transactions
          h[acct.account_id] = {
            currency: acct.currency,
            transactions: { count: txns.length, net_cents: txns.net.fractional },
            credits: { count: txns.credits.length, total_cents: txns.total_credits.fractional },
            debits: { count: txns.debits.length, total_cents: txns.total_debits.fractional },
            balance_cents: stmt.balance&.amount&.fractional
          }
        end
      }
    end

    private

    def extract_filename(resource)
      case resource
      when String then resource
      else resource.respond_to?(:path) ? resource.path : nil
      end
    end

    def read_resource(resource)
      raw = case resource
            when String        then File.read(resource)
            when IO, StringIO  then resource.read
            else raise ArgumentError, "Expected a file path (String) or IO object, got #{resource.class}"
            end

      raw.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
    end

    def build_tokenizer(content)
      if content.lstrip.start_with?('<?')
        Tokenizer::OFX2
      else
        Tokenizer::OFX1
      end
    end
  end
end
