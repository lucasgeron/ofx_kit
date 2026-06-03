# spec/ofx/tokenizer/ofx1_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::Tokenizer::OFX1 do
  let(:content) { File.read(fixture('bank_simple.ofx')) }

  subject(:tokenizer) { described_class.new(content) }

  describe '#headers' do
    it 'parses VERSION from the header section' do
      expect(tokenizer.headers['VERSION']).to eq('102')
    end

    it 'parses ENCODING from the header section' do
      expect(tokenizer.headers['ENCODING']).to eq('USASCII')
    end

    it 'converts NONE values to nil' do
      expect(tokenizer.headers['SECURITY']).to be_nil
    end
  end

  describe '#body' do
    it 'returns a Nokogiri XML document' do
      expect(tokenizer.body).to be_a(Nokogiri::XML::Document)
    end

    it 'contains the OFX root node' do
      expect(tokenizer.body.at_css('OFX')).not_to be_nil
    end

    it 'can find STMTRS nodes' do
      expect(tokenizer.body.css('STMTRS').length).to eq(1)
    end

    it 'can find STMTTRN nodes' do
      expect(tokenizer.body.css('STMTTRN').length).to eq(2)
    end

    it 'reads leaf element content correctly' do
      expect(tokenizer.body.at_css('CURDEF').text.strip).to eq('BRL')
    end

    it 'reads the transaction amount' do
      amounts = tokenizer.body.css('TRNAMT').map { |n| n.text.strip }
      expect(amounts).to contain_exactly('-150.50', '3000.00')
    end
  end

  context 'with a malformed file' do
    let(:content) { File.read(fixture('malformed.ofx')) }

    it 'raises InvalidHeaderError' do
      expect { described_class.new(content) }
        .to raise_error(OFX::Errors::InvalidHeaderError, /Missing <OFX> tag/)
    end
  end
end
