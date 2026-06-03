# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'OFX without CURDEF tag' do
  it 'raises InvalidBodyError — CURDEF is required by the OFX spec (1..1)' do
    expect { OFX::Parser.new(fixture('bank_no_curdef.ofx')) }
      .to raise_error(OFX::Errors::InvalidBodyError, /Missing required CURDEF tag/)
  end
end
