# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::Base::Statement do
  let(:account)      { instance_double(OFX::BankAccount) }
  let(:transactions) { instance_double(OFX::TransactionCollection) }
  let(:balance)      { instance_double(OFX::Balance) }

  subject(:stmt) { described_class.new(account: account, transactions: transactions, balance: balance) }

  it 'exposes account, transactions, and balance' do
    expect(stmt.account).to be(account)
    expect(stmt.transactions).to be(transactions)
    expect(stmt.balance).to be(balance)
  end

  it 'accepts nil balance' do
    s = described_class.new(account: account, transactions: transactions, balance: nil)
    expect(s.balance).to be_nil
  end

  it '#bank_statement? returns false' do
    expect(stmt.bank_statement?).to be false
  end

  it '#credit_card_statement? returns false' do
    expect(stmt.credit_card_statement?).to be false
  end
end
