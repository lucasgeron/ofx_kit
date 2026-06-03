# spec/ofx/parser_spec.rb
# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::Parser do
  describe '.new with a file path' do
    subject(:parser) { described_class.new(fixture('bank_simple.ofx')) }

    it 'exposes statements' do
      expect(parser.statements.length).to eq(1)
      expect(parser.statements.first).to be_a(OFX::BankStatement)
    end

    it '#account returns the statement account' do
      expect(parser.account).to be_a(OFX::BankAccount)
      expect(parser.account.account_id).to eq('12345-6')
    end

    it '#transactions returns all transactions flat' do
      expect(parser.transactions.length).to eq(2)
    end

    it '#balance returns the statement balance' do
      expect(parser.balance).to be_a(OFX::Balance)
      expect(parser.balance.amount.to_d).to eq(BigDecimal('5000.00'))
    end

    it '#filename returns the file path' do
      expect(parser.filename).to end_with('bank_simple.ofx')
    end

    it '#headers exposes OFX header fields' do
      expect(parser.headers['VERSION']).to eq('102')
      expect(parser.headers['ENCODING']).to eq('USASCII')
    end

    it '#summary returns a structured hash with headers and per-account totals' do
      s = parser.summary
      expect(s[:headers]['VERSION']).to eq('102')
      stmt = s[:statements]['12345-6']
      expect(stmt[:currency]).to eq('BRL')
      expect(stmt[:transactions]).to eq({ count: 2, net_cents: 284_950 })
      expect(stmt[:credits]).to eq({ count: 1, total_cents: 300_000 })
      expect(stmt[:debits][:count]).to eq(1)
      expect(stmt[:balance_cents]).to eq(500_000)
    end
  end

  describe '.new with an IO object' do
    it 'parses from an open File' do
      File.open(fixture('bank_simple.ofx')) do |f|
        parser = described_class.new(f)
        expect(parser.account.account_id).to eq('12345-6')
      end
    end

    it 'parses from a StringIO' do
      content = File.read(fixture('bank_simple.ofx'))
      parser  = described_class.new(StringIO.new(content))
      expect(parser.transactions.length).to eq(2)
    end

    it '#filename is nil for a StringIO' do
      parser = described_class.new(StringIO.new(File.read(fixture('bank_simple.ofx'))))
      expect(parser.filename).to be_nil
    end
  end

  describe 'block form' do
    it 'yields self when a block is given' do
      OFX::Parser.new(fixture('bank_simple.ofx')) do |p|
        expect(p.account).to be_a(OFX::BankAccount)
      end
    end
  end

  describe 'OFX version auto-detection' do
    it 'parses OFX 1.x files' do
      parser = described_class.new(fixture('bank_simple.ofx'))
      expect(parser.statements.first).to be_a(OFX::BankStatement)
    end

    it 'parses OFX 2.x files' do
      parser = described_class.new(fixture('bank_ofx2.ofx'))
      expect(parser.statements.first).to be_a(OFX::BankStatement)
      expect(parser.account.account_id).to eq('12345-6')
    end
  end

  describe 'credit card support' do
    it 'parses OFX 1.x credit card statements' do
      parser = described_class.new(fixture('credit_card.ofx'))
      expect(parser.statements.first).to be_a(OFX::CreditCardStatement)
      expect(parser.account).to be_a(OFX::CreditCardAccount)
      expect(parser.transactions.length).to eq(2)
    end

    it 'parses OFX 2.x credit card statements' do
      parser = described_class.new(fixture('credit_card_ofx2.ofx'))
      expect(parser.statements.first).to be_a(OFX::CreditCardStatement)
    end
  end

  describe 'multiple statements per file' do
    subject(:parser) { described_class.new(fixture('bank_multiple.ofx')) }

    it 'returns all statements' do
      expect(parser.statements.length).to eq(2)
    end

    it '#transactions returns all transactions across statements and emits a warning' do
      expect { expect(parser.transactions.length).to eq(2) }
        .to output(/aggregating across \d+ statements/).to_stderr
    end

    it '#transactions emits a hint to disable the warning' do
      expect { parser.transactions }
        .to output(/OFX\.config\.multi_statement_warnings = false/).to_stderr
    end

    context 'when multi_statement_warnings is false' do
      before { OFX.configure { |c| c.multi_statement_warnings = false } }
      after  { OFX.reset_config! }

      it '#transactions does not emit a warning' do
        expect { parser.transactions }.not_to output.to_stderr
      end

      it '#balances does not emit a warning' do
        expect { parser.balances }.not_to output.to_stderr
      end
    end

    it '#account raises MultipleStatementsError mentioning `accounts`' do
      expect { parser.account }
        .to raise_error(OFX::Errors::MultipleStatementsError, /`accounts`/)
    end

    it '#balance raises MultipleStatementsError mentioning `balances`' do
      expect { parser.balance }
        .to raise_error(OFX::Errors::MultipleStatementsError, /`balances`/)
    end

    it '#accounts returns all accounts' do
      expect(parser.accounts.map(&:account_id)).to contain_exactly('11111-1', '22222-2')
    end

    it '#balances returns all balances' do
      expect(parser.balances.map { |b| b.amount.to_d })
        .to contain_exactly(BigDecimal('1000.00'), BigDecimal('10000.00'))
    end
  end

  describe 'fluent chaining' do
    subject(:parser) { described_class.new(fixture('bank_simple.ofx')) }

    it 'supports standard Enumerable on transactions' do
      credits = parser.transactions.select { |t| t.amount > 0 }
      expect(credits.length).to eq(1)
      expect(credits.first.memo).to eq('Deposito salario')
    end

    it 'supports sort_by on transactions' do
      sorted = parser.transactions.sort_by(&:posted_at)
      expect(sorted.first.fit_id).to eq('20240115001')
    end
  end

  describe 'error handling' do
    it 'raises InvalidHeaderError for a malformed file' do
      expect { described_class.new(fixture('malformed.ofx')) }
        .to raise_error(OFX::Errors::InvalidHeaderError)
    end

    it 'raises Errno::ENOENT for a missing file' do
      expect { described_class.new('nonexistent.ofx') }
        .to raise_error(Errno::ENOENT)
    end

    it 'raises ArgumentError when given something other than String or IO' do
      expect { described_class.new(42) }
        .to raise_error(ArgumentError, /Expected a file path.*got Integer/)
    end

    it 'raises InvalidBodyError for a malformed OFX2 file' do
      expect { described_class.new(fixture('malformed_ofx2.ofx')) }
        .to raise_error(OFX::Errors::InvalidBodyError)
    end
  end

  describe 'OFX.configure integration' do
    before do
      OFX.configure do |config|
        config.bank_account.map 'AGENCIA', to: 'branch_code'
        config.transaction.map 'HISPAYEEMEMO', to: 'extended_memo'
      end
    end

    it 'exposes custom-mapped attributes on domain objects' do
      parser = described_class.new(fixture('br_itau.ofx'))
      expect(parser.account.branch_code).to eq('0272')
      expect(parser.transactions.first.extended_memo).to eq('Tarifa bancaria')
    end
  end
end
