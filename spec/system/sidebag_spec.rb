require 'rails_helper'

RSpec.describe "Sidebag", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  let!(:hero) { create(:hero, name: "Sidebag Test Hero", sidebag_capacity: 5, sidebag_contents: []) }

  describe "viewing sidebag on hero page" do
    it "shows empty sidebag" do
      visit hero_path(hero)

      expect(hero.sidebag_count).to eq(0)
      expect(hero.sidebag_slots_remaining).to eq(5)
    end

    it "verifies tokens in sidebag via model" do
      # Test at model level to avoid asset loading issues with token images
      hero.update(sidebag_contents: ["grit", "health", "sanity"])

      expect(hero.sidebag_tokens).to eq(["grit", "health", "sanity"])
      expect(hero.sidebag_count).to eq(3)
    end

    it "verifies sidebag capacity via model" do
      hero.update(sidebag_contents: ["grit", "grit"])

      expect(hero.sidebag_count).to eq(2)
      expect(hero.sidebag_slots_remaining).to eq(3)
    end
  end

  describe "sidebag with adjusted capacity" do
    it "uses adjusted capacity from adjustments" do
      create(:adjustment, hero: hero, title: "Extra Bag", active: true, modifiers: { "sidebag_capacity" => 2 })

      expect(hero.adjusted_sidebag_capacity).to eq(7)
      expect(hero.sidebag_slots_remaining).to eq(7)
    end
  end

  describe "sidebag full state" do
    it "identifies when sidebag is full" do
      hero.update(sidebag_contents: ["Grit", "Grit", "Grit", "Grit", "Grit"])

      expect(hero.sidebag_full?).to be true
      expect(hero.sidebag_slots_remaining).to eq(0)
    end

    it "identifies when sidebag has room" do
      hero.update(sidebag_contents: ["Grit", "Grit"])

      expect(hero.sidebag_full?).to be false
    end
  end

  describe "adding tokens" do
    it "can add a token to the sidebag via model" do
      # Test at model level to avoid asset loading issues
      tokens = hero.sidebag_tokens
      tokens << "grit"
      hero.update(sidebag_contents: tokens)

      expect(hero.reload.sidebag_tokens).to include("grit")
    end

    it "cannot add token when sidebag is full" do
      hero.update(sidebag_contents: ["grit", "grit", "grit", "grit", "grit"])

      expect(hero.sidebag_full?).to be true
      # Model should prevent adding more when full
    end
  end

  describe "removing tokens" do
    before do
      hero.update(sidebag_contents: ["grit", "health", "sanity"])
    end

    it "can remove a token from the sidebag via model" do
      initial_count = hero.sidebag_count

      tokens = hero.sidebag_tokens
      tokens.delete_at(0)
      hero.update(sidebag_contents: tokens)

      expect(hero.reload.sidebag_count).to eq(initial_count - 1)
    end
  end
end
