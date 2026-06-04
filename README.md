# OFX Kit

[![GitHub Repo](https://img.shields.io/badge/OFX%20Kit-blue?label=github&logo=github)](https://github.com/lucasgeron/ofx_kit)
[![Gem Version](https://img.shields.io/gem/v/ofx_kit?logo=rubygems&logoColor=%23e9573f&label=rubygems)](https://rubygems.org/gems/ofx_kit) 
[![Gem Total Downloads](https://img.shields.io/gem/dt/ofx_kit?logo=data%3Aimage%2Fsvg%2Bxml%3Bbase64%2CPHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSI2MDAiIGhlaWdodD0iNjAwIiB2aWV3Qm94PSIwIDAgMjQgMjQiPjxwYXRoIGQ9Ik0xMiAzdjEwbDQtNGgtM1YzaC0ydjZIOGw0IDRWM3pNNSAyMGgxNHYtMkg1djJ6IiBmaWxsPSIjZmZmIi8%2BPC9zdmc%2B&logoColor=white)](https://rubygems.org/gems/ofx_kit)


A Ruby gem for parsing OFX (Open Financial Exchange) files. Supports OFX 1.x (SGML) and OFX 2.x (XML), bank statements and credit card statements, with a fluent API and configurable field mappings.

## Installation

Add to your Gemfile:

```ruby
gem 'ofx_kit', '~> 1.0', '>= 1.0.2'
```

## Usage

### Basic parsing

```ruby
# Parse from a file path
ofx = OFX.new("statement.ofx")

# Parse from an IO object
ofx = OFX.new(File.open("statement.ofx"))
ofx = OFX.new(StringIO.new(raw_content))

# Block form — yields the parser
OFX.new("statement.ofx") do |p|
  puts p.account.account_id
end
```

### Accessing data

```ruby
ofx.filename      # => "statement.ofx" (nil for IO inputs without a path)
ofx.headers       # => { "VERSION" => "102", "ENCODING" => "USASCII", ... }

# Single-statement files
ofx.account       # => OFX::BankAccount or OFX::CreditCardAccount
ofx.transactions  # => Array of OFX::Transaction
ofx.balance       # => OFX::Balance

# Multiple-statement files — use the plural forms
ofx.accounts      # => [OFX::BankAccount, ...]
ofx.statements    # => [OFX::BankStatement, ...]
ofx.balances      # => [OFX::Balance, ...]
```

### Transactions

```ruby
t = ofx.transactions.first

t.fit_id        # => "20240115001"       String
t.type          # => "DEBIT"             String
t.memo          # => "Pagamento boleto"  String
t.posted_at     # => Time object
t.amount        # => Money object (positive = credit, negative = debit)
t.amount_cents  # => Integer (same as t.amount.fractional)

t.amount.currency.iso_code  # => "BRL"
t.amount.to_d               # => BigDecimal("-150.50")
```

### Credits, debits, and scopes

`stmt.transactions` and `account.transactions` both return an `OFX::TransactionCollection`
with `.credits`, `.debits`, `length`, and the full `Enumerable` API:

```ruby
stmt = ofx.statements.first
txns = stmt.transactions           # => OFX::TransactionCollection

txns.length                        # => 2
txns.credits                       # => TransactionCollection of positive amounts
txns.debits                        # => TransactionCollection of negative amounts
txns.total_credits                 # => Money (sum of positive transactions)
txns.total_debits                  # => Money (sum of negative transactions)
txns.net                           # => Money (total_credits + total_debits)
txns.map(&:memo)                   # => ["Pagamento boleto", "Deposito salario"]
txns.sort_by(&:posted_at)          # => Array, sorted by date
```

### Balance

```ruby
bal = ofx.balance
bal.amount        # => Money object
bal.amount_cents  # => Integer
bal.posted_at     # => Time object
```

### Summary

```ruby
ofx.summary
# => {
#   headers: { "VERSION" => "102", ... },
#   statements: {
#     "12345-6" => {
#       currency:      "BRL",
#       transactions:  { count: 2, net_cents: 284_950 },
#       credits:       { count: 1, total_cents: 300_000 },
#       debits:        { count: 1, total_cents: -15_050 },
#       balance_cents: 500_000
#     }
#   }
# }
```

### Error handling

```ruby
OFX.new("missing.ofx")      # => Errno::ENOENT
OFX.new("bad_header.ofx")   # => OFX::InvalidHeaderError
OFX.new("bad_xml.ofx")      # => OFX::InvalidBodyError
OFX.new(42)                 # => ArgumentError

# Calling #account or #balance on a multi-statement file:
ofx.account   # => OFX::MultipleStatementsError (use `accounts`)
ofx.balance   # => OFX::MultipleStatementsError (use `balances`)

```

## Configuration

### Field mappings

Use `map` to add new attributes or rename built-in ones:

```ruby
OFX.configure do |config|
  # New field: your bank emits a tag the gem doesn't know about by default
  config.bank_account.map "AGENCIA",      to: "branch_code"
  config.transaction.map  "HISPAYEEMEMO", to: "extended_memo"

  # Rename a built-in field to a name that fits your domain
  config.transaction.map "FITID", to: "uid"   # default is fit_id
  config.transaction.map "NAME",  to: "payee_name"
end

ofx = OFX.new("statement.ofx")
ofx.account.branch_code               # => "0272"
ofx.transactions.first.extended_memo  # => "Tarifa bancaria"
ofx.transactions.first.uid            # => "20240115001"
# ofx.transactions.first.fit_id       # => nil (FITID is now mapped to uid)
```

> **Protected core fields** — `CURDEF`, `TRNAMT`, `DTPOSTED`, `DTUSER`, `BALAMT`, `DTASOF`
> are used internally to build Money objects and parse dates. They cannot be renamed;
> attempting to do so raises `OFX::ConfigurationError`.

### Loading mappings from a YAML file

For larger configurations or Rails apps, a YAML file is cleaner than inline `map` calls.

**Rails** — eject the template with:

```bash
rails generate ofx:eject
```

This creates `config/initializers/ofx_mappings.yml`, which the gem detects and loads
automatically on boot — no `OFX.configure` call needed.

**Standalone** — point `load_mappings` at any YAML file:

```ruby
OFX.configure do |config|
  config.load_mappings("config/ofx_mappings.yml")
end
```

The file must have a `FIELDS:` top-level key:

```yaml
FIELDS:
  STMTTRN:
    HISPAYEEMEMO: extended_memo   # → transaction.extended_memo (new field)
    FITID: uid                    # → transaction.uid  (default was fit_id)
  BANKACCTFROM:
    AGENCIA: branch_code          # → account.branch_code (new field)
```

### Silencing warnings

`transactions` and `balances` aggregate across all statements in a multi-statement file and emit a warning. To silence them:

```ruby
OFX.config.multi_statement_warnings = false
```

### Currency

The OFX specification requires `CURDEF` in every statement (`STMTRS` / `CCSTMTRS`). If the tag is absent, the gem raises `OFX::Errors::InvalidBodyError` rather than silently assuming a currency.

### Rails

**Behavioral options** — create a standard initializer:

```ruby
# config/initializers/ofx.rb
OFX.configure do |config|
  config.multi_statement_warnings = false  # silence aggregation warnings
end
```

## Contributing

1. Fork the repository and create a feature branch.
2. Install dependencies:

   ```bash
   bundle install
   ```

3. Make your changes. Add or update specs to cover them.
4. Run the test suite and linter before opening a pull request:

   ```bash
   bundle exec rspec
   bundle exec rubocop
   ```

All tests must pass and RuboCop must report no offenses.

### Generating documentation locally

```bash
bundle exec rake rdoc
```

## Testing locally via console

You can exercise the gem interactively using `irb` from the project root. The `spec/fixtures/` directory contains sample OFX files ready to use.

```bash
bundle exec irb -r ./lib/ofx_kit
```

```ruby
# Parse a bank statement (OFX 1.x)
ofx = OFX.new("spec/fixtures/bank_simple.ofx")
ofx.account.account_id   # => "12345-6"
ofx.transactions.length  # => 2
ofx.balance.amount       # => Money object

# Parse an OFX 2.x file
ofx = OFX.new("spec/fixtures/bank_ofx2.ofx")
ofx.headers              # => { "VERSION" => "220", ... }

# Parse a credit card statement
ofx = OFX.new("spec/fixtures/credit_card.ofx")
ofx.account              # => OFX::CreditCardAccount
ofx.transactions.first.amount.to_d  # => BigDecimal

# Multiple statements
ofx = OFX.new("spec/fixtures/bank_multiple.ofx")
ofx.accounts.length      # => 2
ofx.statements.map { |s| s.account.account_id }

# Try custom field mappings
OFX.configure do |config|
  config.transaction.map "HISPAYEEMEMO", to: "extended_memo"
end
ofx = OFX.new("spec/fixtures/bank_simple.ofx")
ofx.transactions.first.extended_memo
OFX.reset_config!  # restore defaults between tests
```

## License

MIT
