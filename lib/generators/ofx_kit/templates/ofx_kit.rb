# config/initializers/ofx_kit.rb

OFX.configure do |config|
  # ---------------------------------------------------------------------------
  # Field Mappings
  # ---------------------------------------------------------------------------
  # Map OFX XML tags to Ruby attribute names on domain objects.
  # Uncomment any line to override its default, or add new lines for custom tags.
  #
  # Protected core fields cannot be remapped (raises OFX::Error::InvalidConfiguration):
  #   CURDEF, TRNAMT, DTPOSTED, DTUSER, BALAMT, DTASOF
  #
  # Default transaction fields (STMTTRN):
  # config.transaction.map "FITID",    to: "fit_id"
  # config.transaction.map "TRNTYPE",  to: "type"
  # config.transaction.map "NAME",     to: "name"
  # config.transaction.map "MEMO",     to: "memo"
  # config.transaction.map "PAYEE",    to: "payee"
  # config.transaction.map "CHECKNUM", to: "check_number"
  # config.transaction.map "REFNUM",   to: "ref_number"
  # config.transaction.map "SIC",      to: "sic"
  # config.transaction.map "HISPAYEEMEMO", to: "extended_memo"  # custom field example
  #
  # Default bank account fields (BANKACCTFROM):
  # config.bank_account.map "BANKID",   to: "bank_id"
  # config.bank_account.map "ACCTID",   to: "account_id"
  # config.bank_account.map "ACCTTYPE", to: "account_type"
  # config.bank_account.map "BRANCHID", to: "branch_id"
  # config.bank_account.map "AGENCIA",  to: "branch_code"  # custom field example
  #
  # Default credit card account fields (CCACCTFROM):
  # config.credit_card_account.map "ACCTID", to: "account_id"

  # ---------------------------------------------------------------------------
  # Behavioral Options
  # ---------------------------------------------------------------------------
  # `transactions` and `balances` emit a warning when aggregating across
  # multiple statements in the same file. Silence them:
  # config.multi_statement_warnings = false
end
