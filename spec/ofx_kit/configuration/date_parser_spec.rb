# frozen_string_literal: true

require 'spec_helper'

class DateParserTestHelper
  include OFX::Configuration::DateParser
  def call(str) = parse_date(str)
end

RSpec.describe OFX::Configuration::DateParser do
  subject(:parser) { DateParserTestHelper.new }

  it 'parses 8-char YYYYMMDD strings' do
    expect(parser.call('20240115')).to eq(Time.strptime('20240115', '%Y%m%d'))
  end

  it 'parses 14-char YYYYMMDDHHMMSS strings' do
    expect(parser.call('20240115143000')).to eq(Time.strptime('20240115143000', '%Y%m%d%H%M%S'))
  end

  it 'strips timezone suffixes before parsing' do
    expect(parser.call('20240115[+05:30]')).to eq(Time.strptime('20240115', '%Y%m%d'))
  end

  it 'returns nil for nil input' do
    expect(parser.call(nil)).to be_nil
  end

  it 'returns nil for empty string' do
    expect(parser.call('')).to be_nil
  end

  it 'returns nil for unparseable strings' do
    expect(parser.call('not-a-date')).to be_nil
  end
end
