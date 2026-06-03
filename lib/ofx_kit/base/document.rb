# frozen_string_literal: true

module OFX
  module Base
    ##
    # Wraps the parsed OFX file, providing access to headers and XML body nodes.
    # Consumers use #bank_statement_nodes and #credit_card_statement_nodes
    # to extract statement data for domain object construction.
    class Document
      ##
      # Parsed OFX header key/value pairs (Hash).
      attr_reader :headers

      ##
      # Creates a new document.
      # +headers+ is a Hash of parsed OFX header key/value pairs.
      # +body+ is a Nokogiri::XML::Document of the parsed OFX body.
      def initialize(headers:, body:)
        @headers = headers
        @body    = body
      end

      ##
      # Returns the OFX version declared in the file header (String or +nil+).
      def version
        @headers['VERSION']
      end

      ##
      # Returns all STMTRS (bank statement) nodes in the document
      # (Nokogiri::XML::NodeSet).
      def bank_statement_nodes
        @body.css('STMTRS')
      end

      ##
      # Returns all CCSTMTRS (credit card statement) nodes in the document
      # (Nokogiri::XML::NodeSet).
      def credit_card_statement_nodes
        @body.css('CCSTMTRS')
      end
    end
  end
end
