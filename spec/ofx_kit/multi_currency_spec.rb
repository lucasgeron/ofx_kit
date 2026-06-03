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

end
