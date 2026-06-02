# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::Base::Document do
  let(:tokenizer) { OFX::Tokenizer::OFX1.new(File.read(fixture('bank_simple.ofx'))) }

  subject(:doc) { described_class.new(headers: tokenizer.headers, body: tokenizer.body) }

  describe '#version' do
    it 'returns the OFX version from headers' do
      expect(doc.version).to eq('102')
    end
  end

  describe '#bank_statement_nodes' do
    it 'returns Nokogiri nodes for each STMTRS block' do
      nodes = doc.bank_statement_nodes
      expect(nodes.length).to eq(1)
      expect(nodes.first.name).to eq('STMTRS')
    end
  end

  describe '#credit_card_statement_nodes' do
    it 'returns empty set for a bank file' do
      expect(doc.credit_card_statement_nodes).to be_empty
    end

    context 'with a credit card fixture' do
      let(:tokenizer) { OFX::Tokenizer::OFX1.new(File.read(fixture('credit_card.ofx'))) }

      it 'returns Nokogiri nodes for each CCSTMTRS block' do
        nodes = doc.credit_card_statement_nodes
        expect(nodes.length).to eq(1)
        expect(nodes.first.name).to eq('CCSTMTRS')
      end
    end
  end

  context 'with a multiple-statement fixture' do
    let(:tokenizer) { OFX::Tokenizer::OFX1.new(File.read(fixture('bank_multiple.ofx'))) }

    it 'returns all STMTRS nodes' do
      expect(doc.bank_statement_nodes.length).to eq(2)
    end
  end

  context 'with OFX2 fixture' do
    let(:tokenizer) { OFX::Tokenizer::OFX2.new(File.read(fixture('bank_ofx2.ofx'))) }

    it 'returns the correct version' do
      expect(doc.version).to eq('211')
    end

    it 'finds STMTRS nodes in OFX2 format' do
      expect(doc.bank_statement_nodes.length).to eq(1)
    end
  end
end
