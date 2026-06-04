# spec/ofx/configuration_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::Configuration do
  subject(:config) { described_class.new }

  describe 'default mappings' do
    it 'loads transaction mappings' do
      expect(config.xml_mappings_for(:transaction)['FITID']).to eq('fit_id')
      expect(config.xml_mappings_for(:transaction)['TRNAMT']).to eq('amount')
      expect(config.xml_mappings_for(:transaction)['MEMO']).to eq('memo')
    end

    it 'loads bank_account mappings' do
      expect(config.xml_mappings_for(:bank_account)['BANKID']).to eq('bank_id')
      expect(config.xml_mappings_for(:bank_account)['ACCTID']).to eq('account_id')
    end

    it 'loads credit_card_account mappings' do
      expect(config.xml_mappings_for(:credit_card_account)['ACCTID']).to eq('account_id')
    end

    it 'loads balance mappings' do
      expect(config.xml_mappings_for(:balance)['BALAMT']).to eq('amount')
    end

    it 'loads core bank_statement currency mapping' do
      expect(config.xml_mappings_for(:bank_statement)['CURDEF']).to eq('currency')
    end

    it 'merges core and user mappings for the same section' do
      expect(config.xml_mappings_for(:transaction)['TRNAMT']).to eq('amount')
      expect(config.xml_mappings_for(:transaction)['FITID']).to eq('fit_id')
    end
  end

  describe 'section proxy' do
    it 'adds a custom XML tag mapping via transaction proxy' do
      config.transaction.map 'HISPAYEEMEMO', to: 'extended_memo'
      expect(config.xml_mappings_for(:transaction)['HISPAYEEMEMO']).to eq('extended_memo')
    end

    it 'adds a custom XML tag mapping via bank_account proxy' do
      config.bank_account.map 'AGENCIA', to: 'branch_code'
      expect(config.xml_mappings_for(:bank_account)['AGENCIA']).to eq('branch_code')
    end

    it 'does not remove default mappings when adding custom ones' do
      config.transaction.map 'CUSTOM', to: 'custom_field'
      expect(config.xml_mappings_for(:transaction)['FITID']).to eq('fit_id')
    end

    it 'raises ConfigurationError when overriding a core transaction field' do
      expect { config.transaction.map 'TRNAMT', to: 'foobar' }
        .to raise_error(OFX::Error::InvalidConfiguration, /Cannot override core mapping.*TRNAMT/)
    end

    it 'raises ConfigurationError when overriding CURDEF on bank_statement' do
      expect { config.bank_statement.map 'CURDEF', to: 'foobar' }
        .to raise_error(OFX::Error::InvalidConfiguration, /Cannot override core mapping.*CURDEF/)
    end

    it 'raises ConfigurationError when the same XML key is mapped twice' do
      config.transaction.map 'HISPAYEEMEMO', to: 'extended_memo'
      expect { config.transaction.map 'HISPAYEEMEMO', to: 'other_attr' }
        .to raise_error(OFX::Error::InvalidConfiguration, /Duplicate mapping.*HISPAYEEMEMO.*extended_memo/)
    end
  end

  describe 'multi_statement_warnings' do
    it 'defaults to true' do
      expect(config.multi_statement_warnings?).to be true
    end

    it 'can be set to false' do
      config.multi_statement_warnings = false
      expect(config.multi_statement_warnings?).to be false
    end
  end
end
