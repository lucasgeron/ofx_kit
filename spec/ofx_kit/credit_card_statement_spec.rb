# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::CreditCardStatement do
  let(:account)      { instance_double(OFX::CreditCardAccount) }
  let(:transactions) { instance_double(OFX::TransactionCollection) }

  subject(:stmt) { described_class.new(account: account, transactions: transactions, balance: nil) }

  it 'is a subclass of OFX::Base::Statement' do
    expect(described_class.ancestors).to include(OFX::Base::Statement)
  end

  it '#credit_card_statement? returns true' do
    expect(stmt.credit_card_statement?).to be true
  end

  it '#bank_statement? returns false' do
    expect(stmt.bank_statement?).to be false
  end
end
