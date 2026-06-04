# config/initializers/ofx_kit.rb

OFX.configure do |config|
  # ---------------------------------------------------------------------------
  # Field Mappings
  # ---------------------------------------------------------------------------
  # Map OFX XML tags to Ruby attribute names on domain objects.
  # Defaults are already loaded — only uncomment what you want to change or add.
  #
  # Protected core fields cannot be remapped (raises OFX::ConfigurationError):
  #   CURDEF, TRNAMT, DTPOSTED, DTUSER, BALAMT, DTASOF
  #
  # Transaction fields (STMTTRN):
  # config.transaction.map "FITID",    to: "fit_id"        # default
  # config.transaction.map "TRNTYPE",  to: "type"          # default
  # config.transaction.map "NAME",     to: "name"          # default
  # config.transaction.map "MEMO",     to: "memo"          # default
  # config.transaction.map "PAYEE",    to: "payee"         # default
  # config.transaction.map "CHECKNUM", to: "check_number"  # default
  # config.transaction.map "REFNUM",   to: "ref_number"    # default
  # config.transaction.map "SIC",      to: "sic"           # default
  # config.transaction.map "HISPAYEEMEMO", to: "extended_memo"  # custom field example
  #
  # Bank account fields (BANKACCTFROM):
  # config.bank_account.map "BANKID",   to: "bank_id"       # default
  # config.bank_account.map "ACCTID",   to: "account_id"    # default
  # config.bank_account.map "ACCTTYPE", to: "account_type"  # default
  # config.bank_account.map "BRANCHID", to: "branch_id"     # default
  # config.bank_account.map "AGENCIA",  to: "branch_code"   # custom field example
  #
  # Credit card account fields (CCACCTFROM):
  # config.credit_card_account.map "ACCTID", to: "account_id"  # default

  # ---------------------------------------------------------------------------
  # Behavioral Options
  # ---------------------------------------------------------------------------
  # `transactions` and `balances` emit a warning when aggregating across
  # multiple statements in the same file. Silence them:
  # config.multi_statement_warnings = false
end
