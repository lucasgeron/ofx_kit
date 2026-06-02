# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] — 2026-06-01

### Added
- Parse OFX 1.x (SGML) and OFX 2.x (XML) files via `OFX.new(path_or_io)`
- `OFX::BankAccount` and `OFX::CreditCardAccount` domain objects
- `OFX::BankStatement` and `OFX::CreditCardStatement` with `account`, `balance`, and `transactions`
- `OFX::TransactionCollection` — `Enumerable` with `.credits`, `.debits`, `.total_credits`, `.total_debits`, `.net`
- `OFX::Balance` with `amount` (Money), `amount_cents`, and `posted_at`
- Configurable field mappings via `OFX.configure` and `OFX.config`
- `OFX.configure { |c| c.transaction.map "TAG", to: :attr }` for custom/renamed fields
- `OFX.config.load_mappings("path/to/mappings.yml")` for YAML-based configuration
- `OFX.config.multi_statement_warnings` flag to silence aggregation warnings
- Rails generator `rails generate ofx:eject` to copy default mappings into the app
- Auto-load of `config/initializers/ofx_mappings.yml` in Rails projects
