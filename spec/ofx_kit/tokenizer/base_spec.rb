# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::Tokenizer::Base do
  let(:concrete_class) do
    Class.new(described_class) do
      def parse!
        @headers = { 'VERSION' => '102' }
        @body    = Nokogiri::XML('<OFX/>')
      end
    end
  end

  subject(:tokenizer) { concrete_class.new('raw content') }

  it 'raises NotImplementedError when #parse! is not implemented' do
    expect { described_class.new('content') }
      .to raise_error(NotImplementedError, /must implement #parse!/)
  end

  it 'exposes parsed headers after initialization' do
    expect(tokenizer.headers).to eq({ 'VERSION' => '102' })
  end

  it 'exposes parsed body after initialization' do
    expect(tokenizer.body).to be_a(Nokogiri::XML::Document)
  end

  describe '#convert_to_utf8' do
    let(:klass) do
      Class.new(described_class) do
        def parse! = nil
        public :convert_to_utf8
      end
    end
    subject(:tok) { klass.new('') }

    it 'returns the string unchanged when already valid UTF-8' do
      expect(tok.convert_to_utf8('hello')).to eq('hello')
    end

    it 'replaces invalid bytes without raising' do
      binary = "\xFF\xFE".b
      expect { tok.convert_to_utf8(binary) }.not_to raise_error
    end
  end
end
