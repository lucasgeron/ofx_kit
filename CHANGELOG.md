# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] — 2026-06-02

### Breaking changes
- `OFX::Configuration#default_currency` removed — currency is always derived from `CURDEF` in the OFX file
- Rails generator renamed from `rails generate ofx:eject` to `rails generate ofx_kit:eject`
- Error classes split into individual files under `lib/ofx_kit/errors/`; require paths changed accordingly

### Changed
- Documentation migrated from YARD (`@return`/`@param`) to RDoc (`##`) throughout the codebase
- `lib/ofx_kit/configuration.rb` removed — submodules (`core`, `section_proxy`, etc.) now loaded directly

### Added
- `rdoc` Rake task configured with `README.md`, `CHANGELOG.md`, and `lib/**/*.rb` as sources
- README section with instructions to generate API docs locally via `rake rdoc`

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
