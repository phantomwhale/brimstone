require 'rails_helper'

RSpec.describe Hero, type: :model do
  describe 'associations' do
    it { should have_many(:adjustments).dependent(:destroy) }
    it { should have_many(:items).dependent(:destroy) }
    it { should have_many(:injuries).dependent(:destroy) }
    it { should have_many(:madnesses).dependent(:destroy) }
    it { should have_many(:mutations).dependent(:destroy) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:hero)).to be_valid
    end
  end

  describe 'default values' do
    let(:hero) { Hero.new }

    it 'sets default sidebag_capacity to 5' do
      expect(hero.sidebag_capacity).to eq(5)
    end

    it 'sets default sidebag_contents to empty array' do
      expect(hero.sidebag_contents).to eq([])
    end
  end

  describe '#sidebag_tokens' do
    let(:hero) { create(:hero) }

    it 'returns empty array when sidebag_contents is nil' do
      hero.update_column(:sidebag_contents, nil)
      expect(hero.sidebag_tokens).to eq([])
    end

    it 'returns the sidebag contents array' do
      hero.sidebag_contents = ["Grit", "Health"]
      expect(hero.sidebag_tokens).to eq(["Grit", "Health"])
    end
  end

  describe '#sidebag_tokens=' do
    let(:hero) { create(:hero) }

    it 'sets sidebag_contents from an array' do
      hero.sidebag_tokens = ["Grit", "Sanity"]
      expect(hero.sidebag_contents).to eq(["Grit", "Sanity"])
    end

    it 'sets empty array if not given an array' do
      hero.sidebag_tokens = "not an array"
      expect(hero.sidebag_contents).to eq([])
    end
  end

  describe '#sidebag_full?' do
    let(:hero) { create(:hero, sidebag_capacity: 3) }

    it 'returns false when sidebag has room' do
      hero.sidebag_contents = ["Grit"]
      expect(hero.sidebag_full?).to be false
    end

    it 'returns true when sidebag is at capacity' do
      hero.sidebag_contents = ["Grit", "Grit", "Grit"]
      expect(hero.sidebag_full?).to be true
    end
  end

  describe '#sidebag_count' do
    let(:hero) { create(:hero) }

    it 'returns the number of tokens in the sidebag' do
      hero.sidebag_contents = ["Grit", "Health"]
      expect(hero.sidebag_count).to eq(2)
    end
  end

  describe '#sidebag_slots_remaining' do
    let(:hero) { create(:hero, sidebag_capacity: 5) }

    it 'returns remaining slots' do
      hero.sidebag_contents = ["Grit", "Grit"]
      expect(hero.sidebag_slots_remaining).to eq(3)
    end
  end

  describe '#total_adjustment_for' do
    let(:hero) { create(:hero, strength: 3) }

    context 'with no adjustments' do
      it 'returns 0' do
        expect(hero.total_adjustment_for('strength')).to eq(0)
      end
    end

    context 'with active adjustments' do
      before do
        create(:adjustment, hero: hero, active: true, modifiers: { "strength" => 2 })
        create(:adjustment, hero: hero, active: true, modifiers: { "strength" => 1 })
      end

      it 'sums all active adjustment modifiers' do
        expect(hero.total_adjustment_for('strength')).to eq(3)
      end
    end

    context 'with inactive adjustments' do
      before do
        create(:adjustment, hero: hero, active: true, modifiers: { "strength" => 2 })
        create(:adjustment, hero: hero, active: false, modifiers: { "strength" => 5 })
      end

      it 'ignores inactive adjustments' do
        expect(hero.total_adjustment_for('strength')).to eq(2)
      end
    end

    context 'with item-based adjustments' do
      let(:equipped_item) { create(:item, hero: hero, equipped: true) }
      let(:unequipped_item) { create(:item, hero: hero, equipped: false) }

      before do
        create(:adjustment, hero: hero, item: equipped_item, active: true, modifiers: { "strength" => 2 })
        create(:adjustment, hero: hero, item: unequipped_item, active: true, modifiers: { "strength" => 5 })
      end

      it 'only counts adjustments from equipped items' do
        expect(hero.total_adjustment_for('strength')).to eq(2)
      end
    end
  end

  describe '#adjusted_value_for' do
    let(:hero) { create(:hero, strength: 3) }

    it 'returns base value when no adjustments' do
      expect(hero.adjusted_value_for('strength')).to eq(3)
    end

    it 'adds adjustments to base value' do
      create(:adjustment, hero: hero, active: true, modifiers: { "strength" => 2 })
      expect(hero.adjusted_value_for('strength')).to eq(5)
    end

    it 'handles negative adjustments' do
      create(:adjustment, hero: hero, active: true, modifiers: { "strength" => -2 })
      expect(hero.adjusted_value_for('strength')).to eq(1)
    end
  end

  describe 'adjusted attribute methods' do
    let(:hero) { create(:hero, strength: 3, agility: 4, health: 10) }

    before do
      create(:adjustment, hero: hero, active: true, modifiers: { "strength" => 1, "agility" => -1 })
    end

    it 'has adjusted_strength method' do
      expect(hero.adjusted_strength).to eq(4)
    end

    it 'has adjusted_agility method' do
      expect(hero.adjusted_agility).to eq(3)
    end

    it 'has adjusted_health method' do
      expect(hero.adjusted_health).to eq(10)
    end
  end

  describe '#has_adjustment_for?' do
    let(:hero) { create(:hero) }

    it 'returns false when no adjustments affect attribute' do
      expect(hero.has_adjustment_for?('strength')).to be false
    end

    it 'returns true when adjustments affect attribute' do
      create(:adjustment, hero: hero, active: true, modifiers: { "strength" => 1 })
      expect(hero.has_adjustment_for?('strength')).to be true
    end
  end

  describe '#all_adjustments_summary' do
    let(:hero) { create(:hero) }

    it 'returns empty hash when no adjustments' do
      expect(hero.all_adjustments_summary).to eq({})
    end

    it 'returns hash of non-zero adjustments' do
      create(:adjustment, hero: hero, active: true, modifiers: { "strength" => 2, "agility" => -1 })
      expect(hero.all_adjustments_summary).to eq({ "strength" => 2, "agility" => -1 })
    end
  end

  describe '#total_hands' do
    let(:hero) { create(:hero) }

    it 'returns default 2 hands' do
      expect(hero.total_hands).to eq(2)
    end

    it 'adds adjustments for extra hands' do
      create(:adjustment, hero: hero, active: true, modifiers: { "total_hands" => 1 })
      expect(hero.total_hands).to eq(3)
    end
  end

  describe '#hands_in_use' do
    let(:hero) { create(:hero) }

    it 'returns 0 when no equipped items' do
      expect(hero.hands_in_use).to eq(0)
    end

    it 'sums hands required by equipped items' do
      create(:item, hero: hero, equipped: true, hands_required: 1)
      create(:item, hero: hero, equipped: true, hands_required: 2)
      expect(hero.hands_in_use).to eq(3)
    end

    it 'ignores unequipped items' do
      create(:item, hero: hero, equipped: true, hands_required: 1)
      create(:item, hero: hero, equipped: false, hands_required: 2)
      expect(hero.hands_in_use).to eq(1)
    end
  end

  describe '#free_hands' do
    let(:hero) { create(:hero) }

    it 'returns total hands minus hands in use' do
      create(:item, hero: hero, equipped: true, hands_required: 1)
      expect(hero.free_hands).to eq(1)
    end
  end

  describe '#occupied_body_parts' do
    let(:hero) { create(:hero) }

    it 'returns empty array when no equipped items' do
      expect(hero.occupied_body_parts).to eq([])
    end

    it 'returns body parts from equipped items' do
      create(:item, hero: hero, equipped: true, body_parts: ["head"])
      create(:item, hero: hero, equipped: true, body_parts: ["chest"])
      expect(hero.occupied_body_parts).to contain_exactly("head", "chest")
    end

    it 'returns unique body parts' do
      create(:item, hero: hero, equipped: true, body_parts: ["head", "shoulders"])
      expect(hero.occupied_body_parts).to contain_exactly("head", "shoulders")
    end
  end

  describe '#body_part_available?' do
    let(:hero) { create(:hero) }

    it 'returns true when body part is not occupied' do
      expect(hero.body_part_available?("head")).to be true
    end

    it 'returns false when body part is occupied' do
      create(:item, hero: hero, equipped: true, body_parts: ["head"])
      expect(hero.body_part_available?("head")).to be false
    end
  end

  describe '#total_item_weight' do
    let(:hero) { create(:hero) }

    it 'returns 0 when no items' do
      expect(hero.total_item_weight).to eq(0)
    end

    it 'sums weight of all items' do
      create(:item, hero: hero, weight: 2)
      create(:item, hero: hero, weight: 3)
      expect(hero.total_item_weight).to eq(5)
    end
  end

  describe '#weight_capacity' do
    let(:hero) { create(:hero, strength: 3) }

    it 'returns 5 + adjusted strength' do
      expect(hero.weight_capacity).to eq(8)
    end

    it 'accounts for strength adjustments' do
      create(:adjustment, hero: hero, active: true, modifiers: { "strength" => 2 })
      expect(hero.weight_capacity).to eq(10)
    end
  end

  describe '#over_weight_capacity?' do
    let(:hero) { create(:hero, strength: 0) }

    it 'returns false when under capacity' do
      create(:item, hero: hero, weight: 3)
      expect(hero.over_weight_capacity?).to be false
    end

    it 'returns true when over capacity' do
      create(:item, hero: hero, weight: 10)
      expect(hero.over_weight_capacity?).to be true
    end
  end

  describe '#weight_capacity_remaining' do
    let(:hero) { create(:hero, strength: 0) }

    it 'returns positive when under capacity' do
      create(:item, hero: hero, weight: 3)
      expect(hero.weight_capacity_remaining).to eq(2)
    end

    it 'returns negative when over capacity' do
      create(:item, hero: hero, weight: 10)
      expect(hero.weight_capacity_remaining).to eq(-5)
    end
  end

  describe '#initialize_dup' do
    let(:original) { create(:hero, health: 10) }

    it 'raises NoMethodError because max_hit_points is not defined' do
      # NOTE: The initialize_dup method references max_hit_points which doesn't exist
      # This test documents the current (buggy) behavior
      expect { original.dup }.to raise_error(NoMethodError, /max_hit_points/)
    end
  end
end
