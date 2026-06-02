# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::TransactionCollection do
  let(:transactions) do
    [
      instance_double(OFX::Transaction, amount: Money.new(300_000, 'BRL')),
      instance_double(OFX::Transaction, amount: Money.new(-15_050, 'BRL'))
    ]
  end

  subject(:collection) { described_class.new(transactions) }

  describe '#length' do
    it 'returns the number of transactions' do
      expect(collection.length).to eq(2)
    end

    it 'returns 0 for an empty collection' do
      expect(described_class.new([]).length).to eq(0)
    end
  end

  describe '#total_credits' do
    it 'returns the sum of positive amounts' do
      expect(collection.total_credits).to eq(Money.new(300_000, 'BRL'))
    end

    it 'returns zero in the default currency when there are no credits' do
      expect(described_class.new([]).total_credits).to eq(Money.new(0, 'USD'))
    end

    it 'returns zero in the account currency when wired to a statement' do
      account  = instance_double(OFX::BankAccount, currency: 'BRL')
      stmt     = instance_double(OFX::BankStatement, account: account)
      col      = described_class.new([])
      col.define_singleton_method(:statement) { stmt }
      expect(col.total_credits).to eq(Money.new(0, 'BRL'))
    end
  end

  describe '#total_debits' do
    it 'returns the sum of negative amounts' do
      expect(collection.total_debits).to eq(Money.new(-15_050, 'BRL'))
    end

    it 'returns zero in the default currency when there are no debits' do
      expect(described_class.new([]).total_debits).to eq(Money.new(0, 'USD'))
    end
  end

  describe '#net' do
    it 'returns credits plus debits' do
      expect(collection.net).to eq(Money.new(284_950, 'BRL'))
    end

    it 'returns zero in the default currency for an empty collection' do
      expect(described_class.new([]).net).to eq(Money.new(0, 'USD'))
    end
  end

  describe '#credits' do
    it 'propagates statement wiring so an empty sub-collection resolves the account currency' do
      account    = instance_double(OFX::BankAccount, currency: 'BRL')
      stmt       = instance_double(OFX::BankStatement, account: account)
      debit_only = [instance_double(OFX::Transaction, amount: Money.new(-100, 'BRL'))]
      col        = described_class.new(debit_only)
      col.define_singleton_method(:statement) { stmt }
      expect(col.credits.total_credits).to eq(Money.new(0, 'BRL'))
    end
  end

  describe '#debits' do
    it 'propagates statement wiring so an empty sub-collection resolves the account currency' do
      account     = instance_double(OFX::BankAccount, currency: 'BRL')
      stmt        = instance_double(OFX::BankStatement, account: account)
      credit_only = [instance_double(OFX::Transaction, amount: Money.new(500, 'BRL'))]
      col         = described_class.new(credit_only)
      col.define_singleton_method(:statement) { stmt }
      expect(col.debits.total_debits).to eq(Money.new(0, 'BRL'))
    end
  end
end
