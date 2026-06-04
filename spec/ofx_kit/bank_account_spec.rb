# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::BankAccount do
  subject(:account) { described_class.new }

  it 'is a subclass of OFX::Base::Account' do
    expect(described_class.ancestors).to include(OFX::Base::Account)
  end

  it 'has bank_id, account_id, account_type, branch_id accessors' do
    account.bank_id      = '0341'
    account.account_id   = '12345-6'
    account.account_type = 'CHECKING'
    account.branch_id    = '001'

    expect(account.bank_id).to eq('0341')
    expect(account.account_id).to eq('12345-6')
    expect(account.account_type).to eq('CHECKING')
    expect(account.branch_id).to eq('001')
  end

  it 'does not define ACCOUNT_TYPES (removed as dead code)' do
    expect(described_class.const_defined?(:ACCOUNT_TYPES)).to be false
  end
end
