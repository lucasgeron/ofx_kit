# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'OFX error hierarchy' do
  it 'OFX::Errors::Error is the base class for all gem errors' do
    expect(OFX::Errors::ParseError.ancestors).to include(OFX::Errors::Error)
    expect(OFX::Errors::InvalidHeaderError.ancestors).to include(OFX::Errors::Error)
    expect(OFX::Errors::InvalidBodyError.ancestors).to include(OFX::Errors::Error)
    expect(OFX::Errors::UnsupportedVersionError.ancestors).to include(OFX::Errors::Error)
    expect(OFX::Errors::EncodingError.ancestors).to include(OFX::Errors::Error)
    expect(OFX::Errors::ConfigurationError.ancestors).to include(OFX::Errors::Error)
    expect(OFX::Errors::MultipleStatementsError.ancestors).to include(OFX::Errors::Error)
  end

  it 'InvalidHeaderError is a ParseError' do
    expect(OFX::Errors::InvalidHeaderError.ancestors).to include(OFX::Errors::ParseError)
  end

  it 'InvalidBodyError is a ParseError' do
    expect(OFX::Errors::InvalidBodyError.ancestors).to include(OFX::Errors::ParseError)
  end

  it 'errors carry a message' do
    error = OFX::Errors::InvalidHeaderError.new('Missing VERSION field')
    expect(error.message).to eq('Missing VERSION field')
  end

  it 'UnsupportedVersionError exposes the version' do
    error = OFX::Errors::UnsupportedVersionError.new('300')
    expect(error.message).to eq('Unsupported OFX version: 300')
    expect(error.version).to eq('300')
  end

  it 'MultipleStatementsError is an OFX::Errors::Error' do
    expect(OFX::Errors::MultipleStatementsError.new('msg').message).to eq('msg')
  end
end
