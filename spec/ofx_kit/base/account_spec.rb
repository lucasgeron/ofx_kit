# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::Base::Account do
  subject(:account) { described_class.new }

  it 'is a subclass of OFX::Base::Entity' do
    expect(described_class.ancestors).to include(OFX::Base::Entity)
  end

  it 'has a currency accessor' do
    account.currency = 'BRL'
    expect(account.currency).to eq('BRL')
  end

  it 'exposes nil placeholder for :statement before builder wiring' do
    expect(account.statement).to be_nil
  end

  it 'exposes nil placeholder for :balance before builder wiring' do
    expect(account.balance).to be_nil
  end

  it 'exposes nil placeholder for :transactions before builder wiring' do
    expect(account.transactions).to be_nil
  end
end
