# spec/ofx/domain/transaction_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::Transaction do
  subject(:transaction) { described_class.new }

  it 'has amount, amount_cents, and typed date fields' do
    transaction.amount       = Money.new(15_050, 'BRL')
    transaction.amount_cents = 15_050
    transaction.posted_at    = Time.new(2024, 1, 15)

    expect(transaction.amount.to_d).to eq(BigDecimal('150.50'))
    expect(transaction.amount_cents).to eq(15_050)
    expect(transaction.posted_at).to be_a(Time)
  end

  it 'supports dynamic custom attributes via ensure_attribute' do
    described_class.ensure_attribute('extended_memo')
    transaction.extended_memo = 'custom data'
    expect(transaction.extended_memo).to eq('custom data')
  end

  it 'does not raise when ensure_attribute is called twice for the same name' do
    expect { described_class.ensure_attribute('dup_field') }.not_to raise_error
    expect { described_class.ensure_attribute('dup_field') }.not_to raise_error
  end
end
