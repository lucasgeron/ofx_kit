# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::Base::Builder do
  def build_document(fixture_name, tokenizer_class = OFX::Tokenizer::OFX1)
    tokenizer = tokenizer_class.new(File.read(fixture(fixture_name)))
    OFX::Base::Document.new(headers: tokenizer.headers, body: tokenizer.body)
  end

  subject(:builder) { described_class.new(build_document('bank_simple.ofx')) }

  describe '#statements' do
    it 'returns an array of statements' do
      expect(builder.statements).to be_an(Array)
      expect(builder.statements.length).to eq(1)
    end

    it 'returns BankStatement objects for STMTRS blocks' do
      expect(builder.statements.first).to be_a(OFX::BankStatement)
    end
  end

  describe 'BankStatement' do
    let(:stmt) { builder.statements.first }

    it 'has a BankAccount' do
      expect(stmt.account).to be_a(OFX::BankAccount)
      expect(stmt.account.bank_id).to eq('0341')
      expect(stmt.account.account_id).to eq('12345-6')
      expect(stmt.account.account_type).to eq('CHECKING')
      expect(stmt.account.currency).to eq('BRL')
    end

    it 'has transactions' do
      expect(stmt.transactions.length).to eq(2)
    end

    it 'stmt.transactions is a TransactionCollection' do
      expect(stmt.transactions).to be_a(OFX::TransactionCollection)
    end

    it 'stmt.transactions supports .credits' do
      expect(stmt.transactions.credits).to be_a(OFX::TransactionCollection)
      expect(stmt.transactions.credits.all? { |t| t.amount.positive? }).to be true
    end

    it 'stmt.transactions supports .debits' do
      expect(stmt.transactions.debits).to be_a(OFX::TransactionCollection)
      expect(stmt.transactions.debits.all? { |t| t.amount.negative? }).to be true
    end

    it 'has a Balance' do
      expect(stmt.balance).to be_a(OFX::Balance)
      expect(stmt.balance.amount.to_d).to eq(BigDecimal('5000.00'))
      expect(stmt.balance.amount_cents).to eq(500_000)
    end

    describe 'account relationships' do
      it 'account.balance delegates to the statement balance' do
        expect(stmt.account.balance).to be(stmt.balance)
      end

      it 'account.transactions delegates to the statement transactions' do
        expect(stmt.account.transactions).to be(stmt.transactions)
      end

      it 'balance.account delegates to the statement account' do
        expect(stmt.balance.account).to be(stmt.account)
      end

      it 'each transaction.account delegates to the statement account' do
        stmt.transactions.each do |t|
          expect(t.account).to be(stmt.account)
        end
      end

      it 'account.statement points back to the statement' do
        expect(stmt.account.statement).to be(stmt)
      end

      it 'balance.statement points back to the statement' do
        expect(stmt.balance.statement).to be(stmt)
      end

      it 'each transaction.statement points back to the statement' do
        stmt.transactions.each do |t|
          expect(t.statement).to be(stmt)
        end
      end

      it 'account carries no back-reference ivars' do
        expect(stmt.account.instance_variables).not_to include(:@statement, :@balance, :@transactions)
      end

      it 'balance carries no back-reference ivars' do
        expect(stmt.balance.instance_variables).not_to include(:@statement, :@account)
      end

      it 'each transaction carries no back-reference ivars' do
        stmt.transactions.each do |t|
          expect(t.instance_variables).not_to include(:@statement, :@account)
        end
      end
    end

    describe 'account.transactions scopes' do
      it 'returns a TransactionCollection' do
        expect(stmt.account.transactions).to be_a(OFX::TransactionCollection)
      end

      it '.credits returns only positive transactions' do
        expect(stmt.account.transactions.credits.all? { |t| t.amount.positive? }).to be true
      end

      it '.debits returns only negative transactions' do
        expect(stmt.account.transactions.debits.all? { |t| t.amount.negative? }).to be true
      end

      it '.credits and .debits return TransactionCollection' do
        expect(stmt.account.transactions.credits).to be_a(OFX::TransactionCollection)
        expect(stmt.account.transactions.debits).to be_a(OFX::TransactionCollection)
      end

      it 'supports Enumerable on scopes' do
        expect(stmt.account.transactions.credits.map(&:memo)).to be_an(Array)
      end
    end

    describe 'transaction totals' do
      it 'total_debits returns Money with sum of negative transactions' do
        expect(stmt.transactions.total_debits).to be_a(Money)
        expect(stmt.transactions.total_debits.to_d).to eq(BigDecimal('-150.50'))
      end

      it 'total_credits returns Money with sum of positive transactions' do
        expect(stmt.transactions.total_credits).to be_a(Money)
        expect(stmt.transactions.total_credits.to_d).to eq(BigDecimal('3000.00'))
      end

      it 'net returns total_credits + total_debits' do
        expect(stmt.transactions.net).to be_a(Money)
        expect(stmt.transactions.net.to_d).to eq(BigDecimal('2849.50'))
      end
    end
  end

  describe 'Transaction' do
    let(:debit) { builder.statements.first.transactions.find { |t| t.type == 'DEBIT' } }
    let(:credit) { builder.statements.first.transactions.find { |t| t.type == 'CREDIT' } }

    it 'parses the debit transaction' do
      expect(debit.fit_id).to eq('20240115001')
      expect(debit.amount).to be_a(Money)
      expect(debit.amount.to_d).to eq(BigDecimal('-150.50'))
      expect(debit.amount_cents).to eq(-15_050)
      expect(debit.memo).to eq('Pagamento boleto')
    end

    it 'parses the credit transaction' do
      expect(credit.amount.to_d).to eq(BigDecimal('3000.00'))
      expect(credit.amount_cents).to eq(300_000)
    end

    it 'parses occurred_at from DTUSER when present' do
      expect(debit.occurred_at).to be_a(Time)
      expect(debit.occurred_at.year).to eq(2024)
      expect(debit.occurred_at.month).to eq(1)
      expect(debit.occurred_at.day).to eq(14)
    end

    it 'occurred_at is nil when DTUSER is absent' do
      expect(credit.occurred_at).to be_nil
    end

    it 'parses posted_at as a Time object' do
      expect(debit.posted_at).to be_a(Time)
      expect(debit.posted_at.year).to eq(2024)
      expect(debit.posted_at.month).to eq(1)
      expect(debit.posted_at.day).to eq(15)
    end

    it 'amount is a Money with the statement currency' do
      expect(debit.amount).to be_a(Money)
      expect(debit.amount.currency.iso_code).to eq('BRL')
    end
  end

  context 'with credit card fixture' do
    subject(:builder) { described_class.new(build_document('credit_card.ofx')) }

    it 'returns CreditCardStatement objects' do
      expect(builder.statements.first).to be_a(OFX::CreditCardStatement)
    end

    it 'has a CreditCardAccount' do
      expect(builder.statements.first.account).to be_a(OFX::CreditCardAccount)
      expect(builder.statements.first.account.account_id).to eq('1234567890123456')
    end

    it 'stmt.transactions is a TransactionCollection' do
      expect(builder.statements.first.transactions).to be_a(OFX::TransactionCollection)
    end
  end

  context 'with multiple statements fixture' do
    subject(:builder) { described_class.new(build_document('bank_multiple.ofx')) }

    it 'returns all statements' do
      expect(builder.statements.length).to eq(2)
    end

    it 'each statement has its own account' do
      ids = builder.statements.map { |s| s.account.account_id }
      expect(ids).to contain_exactly('11111-1', '22222-2')
    end

    it 'each balance knows its account' do
      balances = builder.statements.map(&:balance)
      expect(balances.map { |b| b.account.account_id })
        .to contain_exactly('11111-1', '22222-2')
    end

    it 'each transaction knows its account' do
      builder.statements.each do |stmt|
        stmt.transactions.each do |t|
          expect(t.account).to be(stmt.account)
        end
      end
    end
  end

  context 'with OFX2 bank fixture' do
    subject(:builder) { described_class.new(build_document('bank_ofx2.ofx', OFX::Tokenizer::OFX2)) }

    it 'parses OFX2 statements the same as OFX1' do
      stmt = builder.statements.first
      expect(stmt).to be_a(OFX::BankStatement)
      expect(stmt.account.account_id).to eq('12345-6')
      expect(stmt.transactions.length).to eq(2)
    end
  end

  context 'with custom field mapping (br_itau)' do
    before do
      OFX.configure do |config|
        config.bank_account.map 'AGENCIA', to: 'branch_code'
        config.transaction.map 'HISPAYEEMEMO', to: 'extended_memo'
      end
    end

    subject(:builder) { described_class.new(build_document('br_itau.ofx')) }

    it 'maps the custom AGENCIA tag to branch_code' do
      expect(builder.statements.first.account.branch_code).to eq('0272')
    end

    it 'maps the custom HISPAYEEMEMO tag to extended_memo' do
      t = builder.statements.first.transactions.first
      expect(t.extended_memo).to eq('Tarifa bancaria')
    end
  end
end
