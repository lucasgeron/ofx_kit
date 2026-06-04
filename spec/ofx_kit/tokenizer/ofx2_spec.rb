# spec/ofx/tokenizer/ofx2_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::Tokenizer::OFX2 do
  let(:content) { File.read(fixture('bank_ofx2.ofx')) }

  subject(:tokenizer) { described_class.new(content) }

  describe '#headers' do
    it 'parses VERSION from the processing instruction' do
      expect(tokenizer.headers['VERSION']).to eq('211')
    end

    it 'parses OFXHEADER from the processing instruction' do
      expect(tokenizer.headers['OFXHEADER']).to eq('200')
    end

    it 'converts NONE values to nil' do
      expect(tokenizer.headers['SECURITY']).to be_nil
    end
  end

  context 'with a malformed OFX2 file' do
    let(:content) { File.read(fixture('malformed_ofx2.ofx')) }

    it 'raises InvalidBodyError' do
      expect { described_class.new(content) }
        .to raise_error(OFX::Error::InvalidBody, /OFX2 body/)
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

    it 'reads leaf element content correctly' do
      expect(tokenizer.body.at_css('CURDEF').text.strip).to eq('BRL')
    end

    it 'reads the transaction amounts' do
      amounts = tokenizer.body.css('TRNAMT').map { |n| n.text.strip }
      expect(amounts).to contain_exactly('-150.50', '3000.00')
    end
  end
end
