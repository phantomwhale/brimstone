require 'rails_helper'

RSpec.describe Mutation, type: :model do
  describe 'associations' do
    it { should belong_to(:hero) }
    it { should have_one(:adjustment).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:mutation)).to be_valid
    end
  end

  describe 'default values' do
    let(:mutation) { Mutation.new(hero: create(:hero), name: "Test") }

    it 'sets default modifiers to empty hash' do
      expect(mutation.modifiers).to eq({})
    end
  end

  describe '#from_chart?' do
    let(:hero) { create(:hero) }

    it 'returns true when mutation_key is present' do
      mutation = create(:mutation, hero: hero, mutation_key: "extra_arm")
      expect(mutation.from_chart?).to be true
    end

    it 'returns false when mutation_key is blank' do
      mutation = create(:mutation, hero: hero, mutation_key: nil)
      expect(mutation.from_chart?).to be false
    end
  end

  describe '#has_modifiers?' do
    let(:hero) { create(:hero) }

    it 'returns true when modifiers have non-zero values' do
      mutation = create(:mutation, hero: hero, modifiers: { "total_hands" => 1 })
      expect(mutation.has_modifiers?).to be true
    end

    it 'returns false when modifiers are empty' do
      mutation = create(:mutation, hero: hero, modifiers: {})
      expect(mutation.has_modifiers?).to be false
    end

    it 'returns false when all modifiers are zero' do
      mutation = create(:mutation, hero: hero, modifiers: { "total_hands" => 0 })
      expect(mutation.has_modifiers?).to be false
    end
  end

  describe '#modifier_for' do
    let(:mutation) { create(:mutation, modifiers: { "total_hands" => 1 }) }

    it 'returns the modifier value for an attribute' do
      expect(mutation.modifier_for("total_hands")).to eq(1)
    end

    it 'returns 0 for attributes without modifiers' do
      expect(mutation.modifier_for("strength")).to eq(0)
    end
  end

  describe '#active_modifiers' do
    let(:mutation) { create(:mutation, modifiers: { "total_hands" => 1, "strength" => 0 }) }

    it 'returns only non-zero modifiers' do
      expect(mutation.active_modifiers).to eq({ "total_hands" => 1 })
    end
  end

  describe 'automatic adjustment creation' do
    let(:hero) { create(:hero) }

    context 'when mutation has modifiers' do
      it 'creates an adjustment after create' do
        mutation = create(:mutation, hero: hero, name: "Extra Arm", modifiers: { "total_hands" => 1 })
        expect(mutation.adjustment).to be_present
        expect(mutation.adjustment.title).to eq("Mutation: Extra Arm")
        expect(mutation.adjustment.modifiers).to eq({ "total_hands" => 1 })
      end

      it 'updates adjustment on update' do
        mutation = create(:mutation, hero: hero, name: "Extra Arm", modifiers: { "total_hands" => 1 })
        mutation.update(name: "Powerful Extra Arm", modifiers: { "total_hands" => 1, "strength" => 1 })
        expect(mutation.adjustment.title).to eq("Mutation: Powerful Extra Arm")
        expect(mutation.adjustment.modifiers).to eq({ "total_hands" => 1, "strength" => 1 })
      end
    end

    context 'when mutation has no modifiers' do
      it 'does not create adjustment' do
        mutation = create(:mutation, hero: hero, modifiers: {})
        expect(mutation.adjustment).to be_nil
      end
    end

    context 'when modifiers are removed' do
      it 'destroys adjustment when modifiers become empty' do
        mutation = create(:mutation, hero: hero, modifiers: { "total_hands" => 1 })
        expect(mutation.adjustment).to be_present
        
        mutation.update(modifiers: {})
        expect(mutation.reload.adjustment).to be_nil
      end
    end
  end
end
