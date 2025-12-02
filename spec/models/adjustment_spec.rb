require 'rails_helper'

RSpec.describe Adjustment, type: :model do
  describe 'associations' do
    it { should belong_to(:hero) }
    it { should belong_to(:item).optional }
    it { should belong_to(:injury).optional }
    it { should belong_to(:madness).optional }
    it { should belong_to(:mutation).optional }
  end

  describe 'validations' do
    it { should validate_presence_of(:title) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:adjustment)).to be_valid
    end
  end

  describe 'scopes' do
    let(:hero) { create(:hero) }

    describe '.active' do
      it 'returns only active adjustments' do
        active = create(:adjustment, hero: hero, active: true)
        inactive = create(:adjustment, hero: hero, active: false)

        expect(Adjustment.active).to include(active)
        expect(Adjustment.active).not_to include(inactive)
      end
    end

    describe '.standalone' do
      it 'returns adjustments not linked to items, injuries, madnesses, or mutations' do
        standalone = create(:adjustment, hero: hero)
        item = create(:item, hero: hero)
        with_item = create(:adjustment, hero: hero, item: item)

        expect(Adjustment.standalone).to include(standalone)
        expect(Adjustment.standalone).not_to include(with_item)
      end
    end

    describe '.from_items' do
      it 'returns adjustments linked to items' do
        standalone = create(:adjustment, hero: hero)
        item = create(:item, hero: hero)
        with_item = create(:adjustment, hero: hero, item: item)

        expect(Adjustment.from_items).to include(with_item)
        expect(Adjustment.from_items).not_to include(standalone)
      end
    end

    describe '.from_injuries' do
      it 'returns adjustments linked to injuries' do
        standalone = create(:adjustment, hero: hero)
        injury = create(:injury, hero: hero)
        with_injury = create(:adjustment, hero: hero, injury: injury)

        expect(Adjustment.from_injuries).to include(with_injury)
        expect(Adjustment.from_injuries).not_to include(standalone)
      end
    end

    describe '.from_madnesses' do
      it 'returns adjustments linked to madnesses' do
        standalone = create(:adjustment, hero: hero)
        madness = create(:madness, hero: hero)
        with_madness = create(:adjustment, hero: hero, madness: madness)

        expect(Adjustment.from_madnesses).to include(with_madness)
        expect(Adjustment.from_madnesses).not_to include(standalone)
      end
    end

    describe '.from_mutations' do
      it 'returns adjustments linked to mutations' do
        standalone = create(:adjustment, hero: hero)
        mutation = create(:mutation, hero: hero)
        with_mutation = create(:adjustment, hero: hero, mutation: mutation)

        expect(Adjustment.from_mutations).to include(with_mutation)
        expect(Adjustment.from_mutations).not_to include(standalone)
      end
    end
  end

  describe '#effectively_active?' do
    let(:hero) { create(:hero) }

    context 'standalone adjustment' do
      it 'returns true when active' do
        adjustment = create(:adjustment, hero: hero, active: true)
        expect(adjustment.effectively_active?).to be true
      end

      it 'returns false when inactive' do
        adjustment = create(:adjustment, hero: hero, active: false)
        expect(adjustment.effectively_active?).to be false
      end
    end

    context 'item-based adjustment' do
      it 'returns true when active and item is equipped' do
        item = create(:item, hero: hero, equipped: true)
        adjustment = create(:adjustment, hero: hero, item: item, active: true)
        expect(adjustment.effectively_active?).to be true
      end

      it 'returns false when active but item is not equipped' do
        item = create(:item, hero: hero, equipped: false)
        adjustment = create(:adjustment, hero: hero, item: item, active: true)
        expect(adjustment.effectively_active?).to be false
      end

      it 'returns false when inactive even if item is equipped' do
        item = create(:item, hero: hero, equipped: true)
        adjustment = create(:adjustment, hero: hero, item: item, active: false)
        expect(adjustment.effectively_active?).to be false
      end
    end
  end

  describe 'ADJUSTABLE_ATTRIBUTES' do
    it 'includes expected attributes' do
      expected = %w[health sanity agility cunning spirit strength lore luck
                    initiative combat max_grit corrupt_resist sidebag_capacity
                    total_hands move]
      expect(Adjustment::ADJUSTABLE_ATTRIBUTES).to match_array(expected)
    end
  end

  describe 'default values' do
    let(:adjustment) { Adjustment.new(hero: create(:hero), title: "Test") }

    it 'sets default modifiers to empty hash' do
      expect(adjustment.modifiers).to eq({})
    end

    it 'sets default active to true' do
      expect(adjustment.active).to be true
    end
  end

  describe '#modifier_for' do
    let(:adjustment) { create(:adjustment, modifiers: { "strength" => 2, "agility" => -1 }) }

    it 'returns the modifier value for an attribute' do
      expect(adjustment.modifier_for("strength")).to eq(2)
      expect(adjustment.modifier_for("agility")).to eq(-1)
    end

    it 'returns 0 for attributes without modifiers' do
      expect(adjustment.modifier_for("health")).to eq(0)
    end

    it 'handles symbol keys' do
      expect(adjustment.modifier_for(:strength)).to eq(2)
    end

    it 'handles nil modifiers' do
      adjustment.modifiers = nil
      expect(adjustment.modifier_for("strength")).to eq(0)
    end
  end

  describe '#set_modifier' do
    let(:adjustment) { create(:adjustment, modifiers: {}) }

    it 'sets a modifier value' do
      adjustment.set_modifier("strength", 2)
      expect(adjustment.modifiers["strength"]).to eq(2)
    end

    it 'removes modifier when value is 0' do
      adjustment.modifiers = { "strength" => 2 }
      adjustment.set_modifier("strength", 0)
      expect(adjustment.modifiers).not_to have_key("strength")
    end

    it 'converts values to integers' do
      adjustment.set_modifier("strength", "3")
      expect(adjustment.modifiers["strength"]).to eq(3)
    end
  end

  describe '#active_modifiers' do
    it 'returns only non-zero modifiers' do
      adjustment = create(:adjustment, modifiers: { "strength" => 2, "agility" => 0, "health" => -1 })
      expect(adjustment.active_modifiers).to eq({ "strength" => 2, "health" => -1 })
    end

    it 'handles nil modifiers' do
      adjustment = build(:adjustment)
      adjustment.modifiers = nil
      expect(adjustment.active_modifiers).to eq({})
    end
  end
end
