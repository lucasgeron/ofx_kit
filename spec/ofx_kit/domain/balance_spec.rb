# spec/ofx/domain/balance_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::Balance do
  subject(:balance) { described_class.new }

  it 'exposes amount, amount_cents, and posted_at' do
    balance.amount       = Money.new(500_000, 'BRL')
    balance.amount_cents = 500_000
    balance.posted_at    = Time.new(2024, 1, 31)

    expect(balance.amount.fractional).to eq(500_000)
    expect(balance.amount_cents).to eq(500_000)
    expect(balance.posted_at.year).to eq(2024)
  end
end
