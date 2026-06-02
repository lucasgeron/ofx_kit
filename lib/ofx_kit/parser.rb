# frozen_string_literal: true

module OFX
  # Implementation class for OFX parsing.
  # Prefer the top-level {OFX.new} entry point over instantiating this class directly.
  #
  # @api private
  class Parser
    # @param resource [String, IO] file path or IO object containing OFX data
    # @param block [Proc] optional block; receives the parser instance (arity 1)
    #   or is evaluated in the parser's context (arity != 1)
    def initialize(resource, &block)
      @filename  = extract_filename(resource)
      content    = read_resource(resource)
      tokenizer  = build_tokenizer(content).new(content)
      @document  = Base::Document.new(headers: tokenizer.headers, body: tokenizer.body)
      @statements = Base::Builder.new(@document).statements

      return unless block_given?

      block.arity == 1 ? block.call(self) : instance_eval(&block)
    end

    # @return [Array<BankStatement, CreditCardStatement>] all statements in the file
    # @return [String, nil] original file path, if a path string was provided
    attr_reader :statements, :filename

    # @return [Hash] parsed OFX header fields
    def headers
      @document.headers
    end

    # Returns the account for files containing a single statement.
    # @return [Account, nil]
    # @raise [MultipleStatementsError] if the file contains more than one statement
    def account
      if statements.length > 1
        raise MultipleStatementsError, 'File contains multiple statements. Use `accounts` to get all accounts.'
      end

      statements.first&.account
    end

    # @return [Array<Account>] all accounts across all statements
    def accounts
      statements.map(&:account)
    end

    # Returns all transactions aggregated across all statements.
    # Emits a warning when the file contains multiple statements.
    # @return [TransactionCollection]
    def transactions
      if statements.length > 1 && OFX.config.multi_statement_warnings?
        warn "[OFX] `transactions` is aggregating across #{statements.length} statements. " \
             'For per-account transactions use `statements[i].transactions`. ' \
             'To disable this warning: OFX.config.multi_statement_warnings = false'
      end

      TransactionCollection.new(statements.flat_map { |s| s.transactions.to_a })
    end

    # Returns the balance for files containing a single statement.
    # @return [Balance, nil]
    # @raise [MultipleStatementsError] if the file contains more than one statement
    def balance
      if statements.length > 1
        raise MultipleStatementsError, 'File contains multiple statements. Use `balances` to get all balances.'
      end

      statements.first&.balance
    end

    # @return [Array<Balance, nil>] balances for each statement
    def balances
      if statements.length > 1 && OFX.config.multi_statement_warnings?
        warn "[OFX] `balances` is aggregating across #{statements.length} statements. " \
             'For per-account balance use `statements[i].balance`. ' \
             'To disable this warning: OFX.config.multi_statement_warnings = false'
      end

      statements.map(&:balance)
    end

    # Returns a structured summary of all statements, including transaction counts,
    # credit/debit totals (in cents), and closing balance.
    # @return [Hash]
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
