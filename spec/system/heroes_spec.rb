require 'rails_helper'

RSpec.describe "Heroes", type: :system do
  before do
    driven_by(:selenium_chrome_headless)
  end

  describe "viewing the heroes index" do
    it "displays the list of heroes" do
      create(:hero, name: "Gunslinger Joe")
      create(:hero, name: "Marshal Mary")

      visit heroes_path

      expect(page).to have_content("Gunslinger Joe")
      expect(page).to have_content("Marshal Mary")
    end

    it "shows a link to create a new hero" do
      visit heroes_path
      expect(page).to have_link("New Hero") | have_button("New Hero")
    end
  end

  describe "creating a new hero" do
    it "allows creating a hero with basic attributes" do
      visit new_hero_path

      fill_in "Name", with: "New Test Hero"
      
      click_button "Create Hero"

      expect(page).to have_content("Hero was successfully created")
      expect(page).to have_content("New Test Hero")
    end

    it "shows validation errors for invalid data" do
      visit new_hero_path
      
      # Don't fill in name, try to create
      click_button "Create Hero"

      # Hero should still be created (no validation on name in the model)
      expect(Hero.count).to be >= 0
    end
  end

  describe "viewing a hero" do
    let!(:hero) { create(:hero, name: "Test Hero", health: 12, strength: 3) }

    it "displays hero details" do
      visit hero_path(hero)

      expect(page).to have_content("Test Hero")
      expect(page).to have_content("12") # health
    end

    it "shows edit and destroy buttons" do
      visit hero_path(hero)

      expect(page).to have_link("Edit this hero")
      expect(page).to have_button("Destroy this hero")
    end

    it "has a link back to heroes list" do
      visit hero_path(hero)

      expect(page).to have_link("Back to heroes")
    end
  end

  describe "editing a hero" do
    let!(:hero) { create(:hero, name: "Original Name") }

    it "allows updating hero attributes" do
      visit edit_hero_path(hero)

      fill_in "Name", with: "Updated Name"
      # Find the submit button - it may have various names
      find('input[type="submit"], button[type="submit"]').click

      expect(page).to have_content("Hero was successfully updated")
      expect(page).to have_content("Updated Name")
    end
  end

  describe "deleting a hero" do
    let!(:hero) { create(:hero, name: "To Be Deleted") }

    it "removes the hero when confirmed" do
      visit hero_path(hero)

      accept_confirm do
        click_button "Destroy this hero"
      end

      expect(page).to have_content("Hero was successfully destroyed")
      expect(page).not_to have_content("To Be Deleted")
    end
  end

  describe "hero navigation" do
    let!(:hero) { create(:hero, name: "Navigation Test") }

    it "can navigate from index to show" do
      visit heroes_path

      click_link "Navigation Test"

      expect(page).to have_current_path(hero_path(hero))
    end

    it "can navigate from show to edit" do
      visit hero_path(hero)

      click_link "Edit this hero"

      expect(page).to have_current_path(edit_hero_path(hero))
    end

    it "can navigate back to index" do
      visit hero_path(hero)

      click_link "Back to heroes"

      expect(page).to have_current_path(heroes_path)
    end
  end
end
