# frozen_string_literal: true

module OFX
  module Base
    # Constructs domain objects ({BankStatement}, {CreditCardStatement}, etc.)
    # from a parsed {Base::Document}. Applies field mappings defined in {Configuration}
    # and converts raw OFX values (amounts, dates) into typed Ruby objects.
    class Builder
      include Configuration::DateParser
      include Configuration::MappingApplicator

      def initialize(document)
        @document = document
      end

      # @return [Array<BankStatement, CreditCardStatement>]
      def statements
        @document.bank_statement_nodes.map { |n| build_bank_statement(n) } +
          @document.credit_card_statement_nodes.map { |n| build_credit_card_statement(n) }
      end

      private

      def build_bank_statement(node)
        currency = currency_for(node, :bank_statement)
        account  = build_bank_account(node.at_css(OFX.config.xml_tag_for(:bank_account)), currency)
        txns     = TransactionCollection.new(
          node.css(OFX.config.xml_tag_for(:transaction)).map { |t| build_transaction(t, currency) }
        )
        bal  = build_balance(node.at_css(OFX.config.xml_tag_for(:balance)), currency)
        stmt = BankStatement.new(account: account, transactions: txns, balance: bal)
        wire(stmt)
        stmt
      end

      def build_credit_card_statement(node)
        currency = currency_for(node, :credit_card_statement)
        account  = build_credit_card_account(node.at_css(OFX.config.xml_tag_for(:credit_card_account)), currency)
        txns     = TransactionCollection.new(
          node.css(OFX.config.xml_tag_for(:transaction)).map { |t| build_transaction(t, currency) }
        )
        bal  = build_balance(node.at_css(OFX.config.xml_tag_for(:balance)), currency)
        stmt = CreditCardStatement.new(account: account, transactions: txns, balance: bal)
        wire(stmt)
        stmt
      end

      def build_bank_account(node, currency)
        account = BankAccount.new
        apply_mappings(account, node, :bank_account)
        account.currency ||= currency
        account
      end

      def build_credit_card_account(node, currency)
        account = CreditCardAccount.new
        apply_mappings(account, node, :credit_card_account)
        account.currency ||= currency
        account
      end

      def build_transaction(node, currency)
        t = Transaction.new
        apply_mappings(t, node, :transaction)

        if t.amount
          t.amount       = Money.from_amount(t.amount.to_d, currency)
          t.amount_cents = t.amount.fractional
        end

        t.posted_at   = parse_date(t.posted_at)   if t.posted_at.is_a?(String)
        t.occurred_at = parse_date(t.occurred_at) if t.occurred_at.is_a?(String)

        t
      end

      def build_balance(node, currency)
        return nil unless node

        b = Balance.new
        apply_mappings(b, node, :balance)

        if b.amount
          b.amount       = Money.from_amount(b.amount.to_d, currency)
          b.amount_cents = b.amount.fractional
        end

        b.posted_at = parse_date(b.posted_at) if b.posted_at.is_a?(String)
        b
      end

      def wire(stmt)
        acct = stmt.account
        wire_relations(acct,
                       statement: -> { stmt }, balance: -> { stmt.balance },
                       transactions: -> { stmt.transactions })
        wire_relations(stmt.balance, statement: -> { stmt }, account: -> { acct }) if stmt.balance
        wire_relations(stmt.transactions, statement: -> { stmt })
        stmt.transactions.each { |t| wire_relations(t, statement: -> { stmt }, account: -> { acct }) }
      end

      def wire_relations(obj, **methods) = methods.each { |name, fn| obj.define_singleton_method(name, &fn) }
    end
  end
end
