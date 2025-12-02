require 'rails_helper'

RSpec.describe Madness, type: :model do
  describe 'associations' do
    it { should belong_to(:hero) }
    it { should have_one(:adjustment).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:madness)).to be_valid
    end
  end

  describe 'default values' do
    let(:madness) { Madness.new(hero: create(:hero), name: "Test") }

    it 'sets default modifiers to empty hash' do
      expect(madness.modifiers).to eq({})
    end

    it 'sets default permanent to false' do
      expect(madness.permanent).to be false
    end
  end

  describe '#from_chart?' do
    let(:hero) { create(:hero) }

    it 'returns true when madness_key is present' do
      madness = create(:madness, hero: hero, madness_key: "paranoia")
      expect(madness.from_chart?).to be true
    end

    it 'returns false when madness_key is blank' do
      madness = create(:madness, hero: hero, madness_key: nil)
      expect(madness.from_chart?).to be false
    end
  end

  describe '#has_modifiers?' do
    let(:hero) { create(:hero) }

    it 'returns true when modifiers have non-zero values' do
      madness = create(:madness, hero: hero, modifiers: { "sanity" => -2 })
      expect(madness.has_modifiers?).to be true
    end

    it 'returns false when modifiers are empty' do
      madness = create(:madness, hero: hero, modifiers: {})
      expect(madness.has_modifiers?).to be false
    end

    it 'returns false when all modifiers are zero' do
      madness = create(:madness, hero: hero, modifiers: { "sanity" => 0 })
      expect(madness.has_modifiers?).to be false
    end
  end

  describe '#modifier_for' do
    let(:madness) { create(:madness, modifiers: { "sanity" => -2 }) }

    it 'returns the modifier value for an attribute' do
      expect(madness.modifier_for("sanity")).to eq(-2)
    end

    it 'returns 0 for attributes without modifiers' do
      expect(madness.modifier_for("strength")).to eq(0)
    end
  end

  describe '#active_modifiers' do
    let(:madness) { create(:madness, modifiers: { "sanity" => -2, "spirit" => 0 }) }

    it 'returns only non-zero modifiers' do
      expect(madness.active_modifiers).to eq({ "sanity" => -2 })
    end
  end

  describe 'automatic adjustment creation' do
    let(:hero) { create(:hero) }

    context 'when madness has modifiers' do
      it 'creates an adjustment after create' do
        madness = create(:madness, hero: hero, name: "Paranoia", modifiers: { "cunning" => -1 })
        expect(madness.adjustment).to be_present
        expect(madness.adjustment.title).to eq("Madness: Paranoia")
        expect(madness.adjustment.modifiers).to eq({ "cunning" => -1 })
      end

      it 'updates adjustment on update' do
        madness = create(:madness, hero: hero, name: "Paranoia", modifiers: { "cunning" => -1 })
        madness.update(name: "Severe Paranoia", modifiers: { "cunning" => -2 })
        expect(madness.adjustment.title).to eq("Madness: Severe Paranoia")
        expect(madness.adjustment.modifiers).to eq({ "cunning" => -2 })
      end
    end

    context 'when madness has no modifiers' do
      it 'does not create adjustment' do
        madness = create(:madness, hero: hero, modifiers: {})
        expect(madness.adjustment).to be_nil
      end
    end

    context 'when modifiers are removed' do
      it 'destroys adjustment when modifiers become empty' do
        madness = create(:madness, hero: hero, modifiers: { "cunning" => -1 })
        expect(madness.adjustment).to be_present
        
        madness.update(modifiers: {})
        expect(madness.reload.adjustment).to be_nil
      end
    end
  end
end
