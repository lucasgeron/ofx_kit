# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'OFX error hierarchy' do
  it 'all errors inherit from OFX::Error' do
    expect(OFX::Error::Parse.ancestors).to include(OFX::Error)
    expect(OFX::Error::InvalidHeader.ancestors).to include(OFX::Error)
    expect(OFX::Error::InvalidBody.ancestors).to include(OFX::Error)
    expect(OFX::Error::UnsupportedVersion.ancestors).to include(OFX::Error)
    expect(OFX::Error::UnsupportedEncoding.ancestors).to include(OFX::Error)
    expect(OFX::Error::InvalidConfiguration.ancestors).to include(OFX::Error)
    expect(OFX::Error::MultipleStatements.ancestors).to include(OFX::Error)
  end

  it 'InvalidHeader is a Parse error' do
    expect(OFX::Error::InvalidHeader.ancestors).to include(OFX::Error::Parse)
  end

  it 'InvalidBody is a Parse error' do
    expect(OFX::Error::InvalidBody.ancestors).to include(OFX::Error::Parse)
  end

  it 'errors carry a message' do
    error = OFX::Error::InvalidHeader.new('Missing VERSION field')
    expect(error.message).to eq('Missing VERSION field')
  end

  it 'UnsupportedVersion exposes the version' do
    error = OFX::Error::UnsupportedVersion.new('300')
    expect(error.message).to eq('Unsupported OFX version: 300')
    expect(error.version).to eq('300')
  end

  it 'MultipleStatements carries a message' do
    expect(OFX::Error::MultipleStatements.new('msg').message).to eq('msg')
  end
end
