# frozen_string_literal: true

module OFX
  module Base
    # Wraps the parsed OFX file, providing access to headers and XML body nodes.
    # Consumers use {#bank_statement_nodes} and {#credit_card_statement_nodes}
    # to extract statement data for domain object construction.
    class Document
      attr_reader :headers

      def initialize(headers:, body:)
        @headers = headers
        @body    = body
      end

      # @return [String, nil] OFX version declared in the file header
      def version
        @headers['VERSION']
      end

      # @return [Nokogiri::XML::NodeSet] all STMTRS (bank statement) nodes in the document
      def bank_statement_nodes
        @body.css('STMTRS')
      end

      # @return [Nokogiri::XML::NodeSet] all CCSTMTRS (credit card statement) nodes in the document
      def credit_card_statement_nodes
        @body.css('CCSTMTRS')
      end
    end
  end
end
