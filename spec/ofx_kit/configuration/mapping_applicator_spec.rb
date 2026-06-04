# frozen_string_literal: true

require 'spec_helper'
require 'nokogiri'

class MappingApplicatorTestHelper
  include OFX::Configuration::MappingApplicator
  public :apply_mappings, :currency_for, :text_at
end

RSpec.describe OFX::Configuration::MappingApplicator do
  subject(:applicator) { MappingApplicatorTestHelper.new }

  describe '#text_at' do
    let(:node) { Nokogiri::XML('<root><FOO>  bar  </FOO></root>').root }

    it 'returns the stripped text of the matching element' do
      expect(applicator.text_at(node, 'FOO')).to eq('bar')
    end

    it 'returns nil when the element is absent' do
      expect(applicator.text_at(node, 'MISSING')).to be_nil
    end
  end

  describe '#apply_mappings' do
    let(:node) { Nokogiri::XML('<root><FITID>TX001</FITID></root>').root }
    let(:object) { OFX::Transaction.new }

    it 'assigns mapped fields from the XML node to the object' do
      applicator.apply_mappings(object, node, :transaction)
      expect(object.fit_id).to eq('TX001')
    end

    it 'is a no-op when node is nil' do
      expect { applicator.apply_mappings(object, nil, :transaction) }.not_to raise_error
    end

    it 'skips fields absent from the node' do
      applicator.apply_mappings(object, node, :transaction)
      expect(object.memo).to be_nil
    end
  end

  describe '#currency_for' do
    let(:node_with_currency)    { Nokogiri::XML('<root><CURDEF>BRL</CURDEF></root>').root }
    let(:node_without_currency) { Nokogiri::XML('<root></root>').root }

    it 'returns the currency code from the CURDEF element' do
      expect(applicator.currency_for(node_with_currency, :bank_statement)).to eq('BRL')
    end

    it 'raises InvalidBodyError when CURDEF is absent' do
      expect { applicator.currency_for(node_without_currency, :bank_statement) }
        .to raise_error(OFX::Error::InvalidBody, /Missing required CURDEF tag/)
    end
  end
end
