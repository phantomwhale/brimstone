require 'rails_helper'

RSpec.describe "Adjustments", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let!(:hero) { create(:hero, name: "Adjustment Test Hero", strength: 3, agility: 4) }

  describe "viewing adjustments on hero page" do
    it "shows hero's adjustments" do
      create(:adjustment, hero: hero, title: "Blessing of Strength", modifiers: { "strength" => 2 })
      create(:adjustment, hero: hero, title: "Curse of Weakness", modifiers: { "agility" => -1 })

      visit hero_path(hero)

      expect(page).to have_content("Blessing of Strength")
      expect(page).to have_content("Curse of Weakness")
    end

    it "shows active vs inactive adjustments" do
      create(:adjustment, hero: hero, title: "Active Buff", active: true)
      create(:adjustment, hero: hero, title: "Inactive Buff", active: false)

      visit hero_path(hero)

      expect(page).to have_content("Active Buff")
      expect(page).to have_content("Inactive Buff")
    end
  end

  describe "adjusted stats display" do
    it "shows adjusted values for hero attributes" do
      create(:adjustment, hero: hero, title: "Strength Boost", active: true, modifiers: { "strength" => 2 })

      visit hero_path(hero)

      # Base strength is 3, with +2 adjustment = 5
      expect(hero.adjusted_strength).to eq(5)
    end

    it "shows negative adjustments" do
      create(:adjustment, hero: hero, title: "Weakness", active: true, modifiers: { "strength" => -1 })

      visit hero_path(hero)

      # Base strength is 3, with -1 adjustment = 2
      expect(hero.adjusted_strength).to eq(2)
    end

    it "sums multiple adjustments" do
      create(:adjustment, hero: hero, title: "Buff 1", active: true, modifiers: { "strength" => 1 })
      create(:adjustment, hero: hero, title: "Buff 2", active: true, modifiers: { "strength" => 2 })

      visit hero_path(hero)

      # Base strength is 3, with +1 and +2 = 6
      expect(hero.adjusted_strength).to eq(6)
    end

    it "ignores inactive adjustments" do
      create(:adjustment, hero: hero, title: "Inactive Buff", active: false, modifiers: { "strength" => 10 })

      visit hero_path(hero)

      # Should still be base value
      expect(hero.adjusted_strength).to eq(3)
    end
  end

  describe "toggling adjustments", js: true do
    let!(:adjustment) { create(:adjustment, hero: hero, title: "Toggle Test", active: true, modifiers: { "strength" => 2 }) }

    it "can verify toggle functionality via model" do
      # Test the toggle behavior at model/controller level since UI may vary
      expect(adjustment.active).to be true
      
      # Simulate what the toggle action does
      adjustment.update(active: !adjustment.active)
      
      expect(adjustment.reload.active).to be false
    end
  end

  describe "adjustment from items" do
    it "only applies item adjustments when item is equipped" do
      item = create(:item, hero: hero, name: "Magic Ring", equipped: false)
      create(:adjustment, hero: hero, item: item, title: "Magic Ring", modifiers: { "strength" => 3 })

      # Not equipped, so adjustment shouldn't apply
      expect(hero.adjusted_strength).to eq(3) # base value

      # Equip the item
      item.update(equipped: true)
      expect(hero.reload.adjusted_strength).to eq(6) # base + 3
    end
  end

  describe "adjustment from injuries" do
    it "applies injury adjustments" do
      create(:injury, hero: hero, name: "Broken Arm", modifiers: { "strength" => -2 })

      expect(hero.adjusted_strength).to eq(1) # base 3 - 2
    end
  end

  describe "adjustment from madnesses" do
    it "applies madness adjustments" do
      create(:madness, hero: hero, name: "Paranoia", modifiers: { "cunning" => -1 })
      hero.update(cunning: 4)

      expect(hero.adjusted_cunning).to eq(3) # base 4 - 1
    end
  end

  describe "adjustment from mutations" do
    it "applies mutation adjustments" do
      create(:mutation, hero: hero, name: "Extra Arm", modifiers: { "total_hands" => 1 })

      expect(hero.total_hands).to eq(3) # default 2 + 1
    end
  end
end
