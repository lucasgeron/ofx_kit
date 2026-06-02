# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Multi-bank currency resolution' do
  describe 'file with two statements in different currencies (USD and GBP)' do
    subject(:parser) { OFX::Parser.new(fixture('bank_multi_currency.ofx')) }

    it 'parses two statements' do
      expect(parser.statements.length).to eq(2)
    end

    it 'resolves the USD account currency from CURDEF' do
      usd_account = parser.accounts.find { |a| a.account_id == '55555-5' }
      expect(usd_account.currency).to eq('USD')
    end

    it 'resolves the GBP account currency from CURDEF' do
      gbp_account = parser.accounts.find { |a| a.account_id == '66666-6' }
      expect(gbp_account.currency).to eq('GBP')
    end

    it 'does not mix up currencies between accounts' do
      currencies = parser.accounts.map(&:currency)
      expect(currencies).to contain_exactly('USD', 'GBP')
    end

    it 'uses the correct currency for transaction amounts' do
      usd_stmt = parser.statements.find { |s| s.account.account_id == '55555-5' }
      gbp_stmt = parser.statements.find { |s| s.account.account_id == '66666-6' }

      expect(usd_stmt.transactions.first.amount.currency.iso_code).to eq('USD')
      expect(gbp_stmt.transactions.first.amount.currency.iso_code).to eq('GBP')
    end

    it 'uses the correct currency for balances' do
      usd_stmt = parser.statements.find { |s| s.account.account_id == '55555-5' }
      gbp_stmt = parser.statements.find { |s| s.account.account_id == '66666-6' }

      expect(usd_stmt.balance.amount.currency.iso_code).to eq('USD')
      expect(gbp_stmt.balance.amount.currency.iso_code).to eq('GBP')
    end
  end

  describe 'file with no CURDEF tag' do
    subject(:parser) { OFX::Parser.new(fixture('bank_no_curdef.ofx')) }

    it 'parses one statement' do
      expect(parser.statements.length).to eq(1)
    end

    context 'when default_currency is the built-in default (USD)' do
      it 'falls back to USD on account.currency' do
        expect(parser.account.currency).to eq('USD')
      end

      it 'falls back to USD for transaction amount currency' do
        expect(parser.transactions.first.amount.currency.iso_code).to eq('USD')
      end

      it 'falls back to USD for balance currency' do
        expect(parser.balance.amount.currency.iso_code).to eq('USD')
      end
    end

    context 'when default_currency is configured to EUR' do
      before { OFX.configure { |c| c.default_currency = 'EUR' } }

      it 'falls back to EUR on account.currency' do
        expect(parser.account.currency).to eq('EUR')
      end

      it 'falls back to EUR for transaction amount currency' do
        expect(parser.transactions.first.amount.currency.iso_code).to eq('EUR')
      end

      it 'falls back to EUR for balance currency' do
        expect(parser.balance.amount.currency.iso_code).to eq('EUR')
      end
    end
  end
end
