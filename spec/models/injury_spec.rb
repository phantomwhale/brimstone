require 'rails_helper'

RSpec.describe Injury, type: :model do
  describe 'associations' do
    it { should belong_to(:hero) }
    it { should have_one(:adjustment).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:injury)).to be_valid
    end
  end

  describe 'default values' do
    let(:injury) { Injury.new(hero: create(:hero), name: "Test") }

    it 'sets default modifiers to empty hash' do
      expect(injury.modifiers).to eq({})
    end

    it 'sets default permanent to false' do
      expect(injury.permanent).to be false
    end
  end

  describe '#from_chart?' do
    let(:hero) { create(:hero) }

    it 'returns true when injury_key is present' do
      injury = create(:injury, hero: hero, injury_key: "broken_arm")
      expect(injury.from_chart?).to be true
    end

    it 'returns false when injury_key is blank' do
      injury = create(:injury, hero: hero, injury_key: nil)
      expect(injury.from_chart?).to be false
    end
  end

  describe '#has_modifiers?' do
    let(:hero) { create(:hero) }

    it 'returns true when modifiers have non-zero values' do
      injury = create(:injury, hero: hero, modifiers: { "strength" => -1 })
      expect(injury.has_modifiers?).to be true
    end

    it 'returns false when modifiers are empty' do
      injury = create(:injury, hero: hero, modifiers: {})
      expect(injury.has_modifiers?).to be false
    end

    it 'returns false when all modifiers are zero' do
      injury = create(:injury, hero: hero, modifiers: { "strength" => 0 })
      expect(injury.has_modifiers?).to be false
    end
  end

  describe '#modifier_for' do
    let(:injury) { create(:injury, modifiers: { "strength" => -2 }) }

    it 'returns the modifier value for an attribute' do
      expect(injury.modifier_for("strength")).to eq(-2)
    end

    it 'returns 0 for attributes without modifiers' do
      expect(injury.modifier_for("agility")).to eq(0)
    end
  end

  describe '#active_modifiers' do
    let(:injury) { create(:injury, modifiers: { "strength" => -2, "agility" => 0 }) }

    it 'returns only non-zero modifiers' do
      expect(injury.active_modifiers).to eq({ "strength" => -2 })
    end
  end

  describe 'automatic adjustment creation' do
    let(:hero) { create(:hero) }

    context 'when injury has modifiers' do
      it 'creates an adjustment after create' do
        injury = create(:injury, hero: hero, name: "Broken Leg", modifiers: { "agility" => -1 })
        expect(injury.adjustment).to be_present
        expect(injury.adjustment.title).to eq("Injury: Broken Leg")
        expect(injury.adjustment.modifiers).to eq({ "agility" => -1 })
      end

      it 'updates adjustment on update' do
        injury = create(:injury, hero: hero, name: "Broken Leg", modifiers: { "agility" => -1 })
        injury.update(name: "Badly Broken Leg", modifiers: { "agility" => -2 })
        expect(injury.adjustment.title).to eq("Injury: Badly Broken Leg")
        expect(injury.adjustment.modifiers).to eq({ "agility" => -2 })
      end
    end

    context 'when injury has no modifiers' do
      it 'does not create adjustment' do
        injury = create(:injury, hero: hero, modifiers: {})
        expect(injury.adjustment).to be_nil
      end
    end

    context 'when modifiers are removed' do
      it 'destroys adjustment when modifiers become empty' do
        injury = create(:injury, hero: hero, modifiers: { "agility" => -1 })
        expect(injury.adjustment).to be_present
        
        injury.update(modifiers: {})
        expect(injury.reload.adjustment).to be_nil
      end
    end
  end
end
