require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'associations' do
    it { should belong_to(:hero) }
    it { should have_one(:adjustment).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_numericality_of(:hands_required).is_in(0..3) }
    it { should validate_numericality_of(:weight).is_greater_than_or_equal_to(0) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:item)).to be_valid
    end
  end

  describe 'scopes' do
    let(:hero) { create(:hero) }

    describe '.equipped' do
      it 'returns only equipped items' do
        equipped = create(:item, hero: hero, equipped: true)
        unequipped = create(:item, hero: hero, equipped: false)

        expect(Item.equipped).to include(equipped)
        expect(Item.equipped).not_to include(unequipped)
      end
    end

    describe '.unequipped' do
      it 'returns only unequipped items' do
        equipped = create(:item, hero: hero, equipped: true)
        unequipped = create(:item, hero: hero, equipped: false)

        expect(Item.unequipped).to include(unequipped)
        expect(Item.unequipped).not_to include(equipped)
      end
    end
  end

  describe 'BODY_PARTS' do
    it 'includes expected body parts' do
      expect(Item::BODY_PARTS).to eq(%w[head face shoulders chest legs])
    end
  end

  describe 'default values' do
    let(:item) { Item.new(hero: create(:hero), name: "Test") }

    it 'sets default equipped to false' do
      expect(item.equipped).to be false
    end

    it 'sets default body_parts to empty array' do
      expect(item.body_parts).to eq([])
    end

    it 'sets default hands_required to 0' do
      expect(item.hands_required).to eq(0)
    end

    it 'sets default weight to 0' do
      expect(item.weight).to eq(0)
    end
  end

  describe '#requires_body_parts?' do
    let(:hero) { create(:hero) }

    it 'returns true when item has body parts' do
      item = create(:item, hero: hero, body_parts: ["head"])
      expect(item.requires_body_parts?).to be true
    end

    it 'returns false when item has no body parts' do
      item = create(:item, hero: hero, body_parts: [])
      expect(item.requires_body_parts?).to be false
    end
  end

  describe '#requires_hands?' do
    let(:hero) { create(:hero) }

    it 'returns true when item requires hands' do
      item = create(:item, hero: hero, hands_required: 1)
      expect(item.requires_hands?).to be true
    end

    it 'returns false when item requires no hands' do
      item = create(:item, hero: hero, hands_required: 0)
      expect(item.requires_hands?).to be false
    end
  end

  describe '#equippable?' do
    let(:hero) { create(:hero) }

    it 'returns true when item requires body parts' do
      item = create(:item, hero: hero, body_parts: ["head"])
      expect(item.equippable?).to be true
    end

    it 'returns true when item requires hands' do
      item = create(:item, hero: hero, hands_required: 1)
      expect(item.equippable?).to be true
    end

    it 'returns false when item requires neither' do
      item = create(:item, hero: hero, body_parts: [], hands_required: 0)
      expect(item.equippable?).to be false
    end
  end

  describe '#body_parts_array' do
    let(:hero) { create(:hero) }

    it 'returns body_parts as array' do
      item = create(:item, hero: hero, body_parts: ["head", "shoulders"])
      expect(item.body_parts_array).to eq(["head", "shoulders"])
    end

    it 'returns empty array when body_parts is not an array' do
      item = build(:item, hero: hero)
      item.body_parts = nil
      expect(item.body_parts_array).to eq([])
    end
  end

  describe '#body_parts_array=' do
    let(:item) { build(:item) }

    it 'sets body_parts from array' do
      item.body_parts_array = ["head", "chest"]
      expect(item.body_parts).to eq(["head", "chest"])
    end

    it 'filters out blank values' do
      item.body_parts_array = ["head", "", "chest", nil]
      expect(item.body_parts).to eq(["head", "chest"])
    end

    it 'handles non-array input' do
      item.body_parts_array = "head"
      expect(item.body_parts).to eq([])
    end
  end

  describe '#can_equip?' do
    let(:hero) { create(:hero) }

    context 'non-equippable item' do
      it 'returns true for non-equippable items' do
        item = create(:item, hero: hero, body_parts: [], hands_required: 0)
        expect(item.can_equip?).to be true
      end
    end

    context 'already equipped item' do
      it 'returns false' do
        item = create(:item, hero: hero, body_parts: ["head"], equipped: true)
        expect(item.can_equip?).to be false
      end
    end

    context 'body part conflicts' do
      it 'returns false when body part is occupied' do
        create(:item, hero: hero, body_parts: ["head"], equipped: true)
        item = create(:item, hero: hero, body_parts: ["head"], equipped: false)
        expect(item.can_equip?).to be false
      end

      it 'returns true when body part is available' do
        item = create(:item, hero: hero, body_parts: ["head"], equipped: false)
        expect(item.can_equip?).to be true
      end
    end

    context 'hand requirements' do
      it 'returns false when not enough free hands' do
        create(:item, hero: hero, hands_required: 2, equipped: true)
        item = create(:item, hero: hero, hands_required: 1, equipped: false)
        expect(item.can_equip?).to be false
      end

      it 'returns true when enough free hands' do
        item = create(:item, hero: hero, hands_required: 1, equipped: false)
        expect(item.can_equip?).to be true
      end
    end
  end

  describe '#cannot_equip_reason' do
    let(:hero) { create(:hero) }

    it 'returns nil when item can be equipped' do
      item = create(:item, hero: hero, hands_required: 1, equipped: false)
      expect(item.cannot_equip_reason).to be_nil
    end

    it 'returns "Already equipped" when equipped' do
      item = create(:item, hero: hero, body_parts: ["head"], equipped: true)
      expect(item.cannot_equip_reason).to eq("Already equipped")
    end

    it 'returns body part conflict message' do
      create(:item, hero: hero, body_parts: ["head"], equipped: true)
      item = create(:item, hero: hero, body_parts: ["head"], equipped: false)
      expect(item.cannot_equip_reason).to include("Head")
    end

    it 'returns hand availability message' do
      create(:item, hero: hero, hands_required: 2, equipped: true)
      item = create(:item, hero: hero, hands_required: 1, equipped: false)
      expect(item.cannot_equip_reason).to include("Not enough free hands")
    end
  end

  describe '#equip!' do
    let(:hero) { create(:hero) }

    it 'equips the item when possible' do
      item = create(:item, hero: hero, hands_required: 1, equipped: false)
      expect(item.equip!).to be true
      expect(item.reload.equipped).to be true
    end

    it 'returns false when cannot equip' do
      create(:item, hero: hero, hands_required: 2, equipped: true)
      item = create(:item, hero: hero, hands_required: 1, equipped: false)
      expect(item.equip!).to be false
      expect(item.reload.equipped).to be false
    end
  end

  describe '#unequip!' do
    let(:hero) { create(:hero) }

    it 'unequips the item' do
      item = create(:item, hero: hero, equipped: true)
      item.unequip!
      expect(item.reload.equipped).to be false
    end
  end

  describe '#adjustment_for_form' do
    let(:hero) { create(:hero) }

    it 'returns existing adjustment' do
      item = create(:item, hero: hero)
      adjustment = create(:adjustment, hero: hero, item: item)
      expect(item.adjustment_for_form).to eq(adjustment)
    end

    it 'builds new adjustment when none exists' do
      item = create(:item, hero: hero, name: "Test Item")
      adjustment = item.adjustment_for_form
      expect(adjustment).to be_a(Adjustment)
      expect(adjustment).to be_new_record
      expect(adjustment.title).to eq("Test Item")
    end
  end

  describe '#has_modifiers?' do
    let(:hero) { create(:hero) }

    it 'returns false when no adjustment' do
      item = create(:item, hero: hero)
      expect(item.has_modifiers?).to be false
    end

    it 'returns false when adjustment has no active modifiers' do
      item = create(:item, hero: hero)
      create(:adjustment, hero: hero, item: item, modifiers: {})
      expect(item.has_modifiers?).to be false
    end

    it 'returns true when adjustment has active modifiers' do
      item = create(:item, hero: hero)
      create(:adjustment, hero: hero, item: item, modifiers: { "strength" => 1 })
      expect(item.has_modifiers?).to be true
    end
  end

  describe 'nested adjustment attributes' do
    let(:hero) { create(:hero) }

    it 'accepts nested attributes for adjustment' do
      item = Item.create!(
        hero: hero,
        name: "Magic Sword",
        adjustment_attributes: {
          hero_id: hero.id,
          title: "Magic Sword",
          modifiers: { "strength" => 2 }
        }
      )
      expect(item.adjustment).to be_present
      expect(item.adjustment.modifiers["strength"]).to eq(2)
    end

    it 'rejects adjustment when all modifiers are blank' do
      item = Item.create!(
        hero: hero,
        name: "Plain Sword",
        adjustment_attributes: {
          hero_id: hero.id,
          title: "Plain Sword",
          modifiers: { "strength" => 0 }
        }
      )
      expect(item.adjustment).to be_nil
    end
  end
end
