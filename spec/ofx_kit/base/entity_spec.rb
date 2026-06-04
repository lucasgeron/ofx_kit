# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OFX::Base::Entity do
  let(:klass) { Class.new(described_class) }
  subject(:entity) { klass.new }

  describe '.ensure_attribute' do
    it 'adds an attr_accessor for a Symbol name' do
      klass.ensure_attribute(:custom_field)
      entity.custom_field = 'hello'
      expect(entity.custom_field).to eq('hello')
    end

    it 'accepts a String name' do
      klass.ensure_attribute('string_field')
      entity.string_field = 42
      expect(entity.string_field).to eq(42)
    end

    it 'is idempotent when called twice for the same name' do
      expect { klass.ensure_attribute(:dup_field) }.not_to raise_error
      expect { klass.ensure_attribute(:dup_field) }.not_to raise_error
    end
  end

  describe '.wired_by_builder' do
    it 'creates a nil-returning placeholder for a single relation' do
      klass.wired_by_builder(:some_relation)
      expect(entity.some_relation).to be_nil
    end

    it 'accepts multiple relation names at once' do
      klass.wired_by_builder(:rel_a, :rel_b)
      expect(entity.rel_a).to be_nil
      expect(entity.rel_b).to be_nil
    end
  end
end
