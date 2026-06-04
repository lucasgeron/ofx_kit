# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'OFX error hierarchy' do
  it 'OFX::Error is the base class for all gem errors' do
    expect(OFX::ParseError.ancestors).to include(OFX::Error)
    expect(OFX::InvalidHeaderError.ancestors).to include(OFX::Error)
    expect(OFX::InvalidBodyError.ancestors).to include(OFX::Error)
    expect(OFX::UnsupportedVersionError.ancestors).to include(OFX::Error)
    expect(OFX::EncodingError.ancestors).to include(OFX::Error)
    expect(OFX::ConfigurationError.ancestors).to include(OFX::Error)
    expect(OFX::MultipleStatementsError.ancestors).to include(OFX::Error)
  end

  it 'InvalidHeaderError is a ParseError' do
    expect(OFX::InvalidHeaderError.ancestors).to include(OFX::ParseError)
  end

  it 'InvalidBodyError is a ParseError' do
    expect(OFX::InvalidBodyError.ancestors).to include(OFX::ParseError)
  end

  it 'errors carry a message' do
    error = OFX::InvalidHeaderError.new('Missing VERSION field')
    expect(error.message).to eq('Missing VERSION field')
  end

  it 'UnsupportedVersionError exposes the version' do
    error = OFX::UnsupportedVersionError.new('300')
    expect(error.message).to eq('Unsupported OFX version: 300')
    expect(error.version).to eq('300')
  end

  it 'MultipleStatementsError is an OFX::Error' do
    expect(OFX::MultipleStatementsError.new('msg').message).to eq('msg')
  end
end
