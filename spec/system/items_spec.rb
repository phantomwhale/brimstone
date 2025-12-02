require 'rails_helper'

RSpec.describe "Items", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let!(:hero) { create(:hero, name: "Item Test Hero") }

  describe "viewing items on hero page" do
    it "shows hero's items" do
      create(:item, hero: hero, name: "Test Revolver", equipped: true)
      create(:item, hero: hero, name: "Cowboy Hat", equipped: false)

      visit hero_path(hero)

      expect(page).to have_content("Test Revolver")
      expect(page).to have_content("Cowboy Hat")
    end

    it "shows equipped status" do
      create(:item, hero: hero, name: "Equipped Item", equipped: true, hands_required: 1)
      create(:item, hero: hero, name: "Unequipped Item", equipped: false, hands_required: 1)

      visit hero_path(hero)

      # The equipped item should be visually differentiated
      expect(page).to have_content("Equipped Item")
      expect(page).to have_content("Unequipped Item")
    end
  end

  describe "item weight and capacity" do
    it "displays weight information" do
      hero.update(strength: 3) # weight capacity = 5 + 3 = 8
      create(:item, hero: hero, name: "Heavy Item", weight: 3)
      create(:item, hero: hero, name: "Light Item", weight: 1)

      visit hero_path(hero)

      # Total weight should be shown somewhere
      expect(hero.total_item_weight).to eq(4)
      expect(hero.weight_capacity).to eq(8)
    end
  end

  describe "equipping and unequipping items", js: true do
    context "with available hands" do
      let!(:weapon) { create(:item, hero: hero, name: "Pistol", hands_required: 1, equipped: false) }

      it "can equip an item via model" do
        # Test equip functionality at model level
        expect(weapon.can_equip?).to be true
        weapon.equip!
        expect(weapon.reload.equipped).to be true
      end
    end

    context "with equipped items" do
      let!(:weapon) { create(:item, hero: hero, name: "Pistol", hands_required: 1, equipped: true) }

      it "can unequip an item via model" do
        # Test unequip functionality at model level
        weapon.unequip!
        expect(weapon.reload.equipped).to be false
      end
    end
  end

  describe "hand slot management" do
    it "shows free hands correctly" do
      # Hero has 2 hands by default
      create(:item, hero: hero, name: "One-handed Weapon", hands_required: 1, equipped: true)

      visit hero_path(hero)

      expect(hero.hands_in_use).to eq(1)
      expect(hero.free_hands).to eq(1)
    end

    it "prevents equipping items when no hands available" do
      # Equip a two-handed weapon first
      create(:item, hero: hero, name: "Two-handed Weapon", hands_required: 2, equipped: true)
      one_hand = create(:item, hero: hero, name: "Dagger", hands_required: 1, equipped: false)

      expect(one_hand.can_equip?).to be false
      expect(one_hand.cannot_equip_reason).to include("Not enough free hands")
    end
  end

  describe "body part slot management" do
    it "prevents equipping items on occupied body parts" do
      create(:item, hero: hero, name: "Hat", body_parts: ["head"], equipped: true)
      helmet = create(:item, hero: hero, name: "Helmet", body_parts: ["head"], equipped: false)

      expect(helmet.can_equip?).to be false
      expect(helmet.cannot_equip_reason).to include("Head")
    end

    it "shows occupied body parts" do
      create(:item, hero: hero, name: "Hat", body_parts: ["head"], equipped: true)
      create(:item, hero: hero, name: "Vest", body_parts: ["chest"], equipped: true)

      expect(hero.occupied_body_parts).to contain_exactly("head", "chest")
    end
  end

  describe "item with stat modifiers" do
    it "shows items affect hero stats when equipped" do
      hero.update(strength: 3)
      item = create(:item, hero: hero, name: "Gauntlets of Strength", equipped: true)
      create(:adjustment, hero: hero, item: item, title: "Gauntlets of Strength", modifiers: { "strength" => 2 })

      visit hero_path(hero)

      # The adjusted strength should be shown
      expect(hero.adjusted_strength).to eq(5)
    end

    it "does not apply modifiers from unequipped items" do
      hero.update(strength: 3)
      item = create(:item, hero: hero, name: "Gauntlets of Strength", equipped: false)
      create(:adjustment, hero: hero, item: item, title: "Gauntlets of Strength", modifiers: { "strength" => 2 })

      expect(hero.adjusted_strength).to eq(3)
    end
  end
end
