# spec/ofx/configuration_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::Configuration do
  subject(:config) { described_class.new }

  describe 'default mappings' do
    it 'loads transaction mappings from YAML' do
      expect(config.xml_mappings_for(:transaction)['FITID']).to eq('fit_id')
      expect(config.xml_mappings_for(:transaction)['TRNAMT']).to eq('amount')
      expect(config.xml_mappings_for(:transaction)['MEMO']).to eq('memo')
    end

    it 'loads bank_account mappings from YAML' do
      expect(config.xml_mappings_for(:bank_account)['BANKID']).to eq('bank_id')
      expect(config.xml_mappings_for(:bank_account)['ACCTID']).to eq('account_id')
    end

    it 'loads credit_card_account mappings from YAML' do
      expect(config.xml_mappings_for(:credit_card_account)['ACCTID']).to eq('account_id')
    end

    it 'loads balance mappings from YAML' do
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
        .to raise_error(OFX::ConfigurationError, /Cannot override core mapping.*TRNAMT/)
    end

    it 'raises ConfigurationError when overriding CURDEF on bank_statement' do
      expect { config.bank_statement.map 'CURDEF', to: 'foobar' }
        .to raise_error(OFX::ConfigurationError, /Cannot override core mapping.*CURDEF/)
    end
  end

  describe 'auto-load from project path' do
    let(:auto_load_path) { File.join(__dir__, '../fixtures/auto_mappings.yml') }

    after { File.delete(auto_load_path) if File.exist?(auto_load_path) }

    it 'loads the project file on top of gem defaults when it exists' do
      File.write(auto_load_path, "FIELDS:\n  STMTTRN:\n    CUSTFIELD: \"auto_attr\"\n")
      config = described_class.new(auto_load_path: auto_load_path)
      expect(config.xml_mappings_for(:transaction)['CUSTFIELD']).to eq('auto_attr')
      expect(config.xml_mappings_for(:transaction)['FITID']).to eq('fit_id')
    end

    it 'skips auto-load when the project file does not exist' do
      config = described_class.new(auto_load_path: '/nonexistent/ofx_mappings.yml')
      expect(config.xml_mappings_for(:transaction)['FITID']).to eq('fit_id')
    end

    it 'raises ConfigurationError when auto-loaded file tries to override a core field' do
      File.write(auto_load_path, "FIELDS:\n  STMTTRN:\n    TRNAMT: \"foobar\"\n")
      expect { described_class.new(auto_load_path: auto_load_path) }
        .to raise_error(OFX::ConfigurationError, /Cannot override core mapping.*TRNAMT/)
    end
  end

  describe '#load_mappings' do
    let(:custom_yaml_path) { File.join(__dir__, '../fixtures/custom_mappings.yml') }

    before do
      File.write(custom_yaml_path, <<~YAML)
        FIELDS:
          STMTTRN:
            CUSTFIELD: "custom_attr"
      YAML
    end

    after { File.delete(custom_yaml_path) if File.exist?(custom_yaml_path) }

    it 'merges custom YAML on top of defaults' do
      config.load_mappings(custom_yaml_path)
      expect(config.xml_mappings_for(:transaction)['CUSTFIELD']).to eq('custom_attr')
      expect(config.xml_mappings_for(:transaction)['FITID']).to eq('fit_id')
    end

    it 'raises ConfigurationError for a missing file' do
      expect { config.load_mappings('nonexistent.yml') }
        .to raise_error(OFX::ConfigurationError, /not found/)
    end

    it 'raises ConfigurationError when FIELDS key is missing' do
      File.write(custom_yaml_path, "STMTTRN:\n  FOO: bar\n")
      expect { config.load_mappings(custom_yaml_path) }
        .to raise_error(OFX::ConfigurationError, /missing.*FIELDS/)
    end

    it 'does not raise when FIELDS is present and OPTIONS is absent' do
      File.write(custom_yaml_path, "FIELDS:\n  STMTTRN:\n    CUSTFIELD: custom_attr\n")
      expect { config.load_mappings(custom_yaml_path) }.not_to raise_error
    end

    it 'raises ConfigurationError for an unknown XML tag' do
      File.write(custom_yaml_path, "FIELDS:\n  UNKNOWN_TAG:\n    FOO: bar\n")
      expect { config.load_mappings(custom_yaml_path) }
        .to raise_error(OFX::ConfigurationError, /Unknown section/)
    end

    it 'raises ConfigurationError when a mapping value is not a Hash' do
      File.write(custom_yaml_path, "FIELDS:\n  STMTTRN: \"oops this should be a hash\"\n")
      expect { config.load_mappings(custom_yaml_path) }
        .to raise_error(OFX::ConfigurationError, /must be a Hash/)
    end

    it 'raises ConfigurationError when overriding a core field via load_mappings' do
      File.write(custom_yaml_path, "FIELDS:\n  STMTTRN:\n    TRNAMT: \"foobar\"\n")
      expect { config.load_mappings(custom_yaml_path) }
        .to raise_error(OFX::ConfigurationError, /Cannot override core mapping.*TRNAMT/)
    end

    it 'raises ConfigurationError when overriding CURDEF via load_mappings' do
      File.write(custom_yaml_path, "FIELDS:\n  STMTRS:\n    CURDEF: \"foobar\"\n")
      expect { config.load_mappings(custom_yaml_path) }
        .to raise_error(OFX::ConfigurationError, /Cannot override core mapping.*CURDEF/)
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

  describe 'default_currency' do
    it 'defaults to USD' do
      expect(config.default_currency).to eq('USD')
    end

    it 'can be configured' do
      config.default_currency = 'BRL'
      expect(config.default_currency).to eq('BRL')
    end
  end
end
