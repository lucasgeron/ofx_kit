# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::CreditCardAccount do
  subject(:account) { described_class.new }

  it 'is a subclass of OFX::Base::Account' do
    expect(described_class.ancestors).to include(OFX::Base::Account)
  end

  it 'has account_id accessor' do
    account.account_id = '4111111111111111'
    expect(account.account_id).to eq('4111111111111111')
  end

  it 'inherits currency from OFX::Base::Account' do
    account.currency = 'USD'
    expect(account.currency).to eq('USD')
  end
end
