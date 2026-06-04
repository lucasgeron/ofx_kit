# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::Configuration::SectionProxy do
  let(:user_fields) { {} }
  let(:core_fields) { { 'transaction' => { 'TRNAMT' => 'amount' } } }

  subject(:proxy) { described_class.new(user_fields, core_fields, :transaction) }

  it 'adds a user field mapping' do
    proxy.map('HISPAYEEMEMO', to: 'extended_memo')
    expect(user_fields[:transaction]['HISPAYEEMEMO']).to eq('extended_memo')
  end

  it 'accepts a Symbol as the to: value' do
    proxy.map('MYFIELD', to: :my_attr)
    expect(user_fields[:transaction]['MYFIELD']).to eq(:my_attr)
  end

  it 'raises ConfigurationError when overriding a core field' do
    expect { proxy.map('TRNAMT', to: 'foobar') }
      .to raise_error(OFX::ConfigurationError, /Cannot override core mapping.*TRNAMT/)
  end

  it 'raises ConfigurationError when mapping the same XML key twice' do
    proxy.map('HISPAYEEMEMO', to: 'first')
    expect { proxy.map('HISPAYEEMEMO', to: 'second') }
      .to raise_error(OFX::ConfigurationError, /Duplicate mapping.*HISPAYEEMEMO.*first/)
  end
end
