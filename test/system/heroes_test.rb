require "application_system_test_case"

class HeroesTest < ApplicationSystemTestCase
  setup do
    @hero = heroes(:one)
  end

  test "visiting the index" do
    visit heroes_url
    assert_selector "h1", text: "Heroes"
  end

  test "should create hero" do
    visit heroes_url
    click_on "New hero"

    fill_in "Agility", with: @hero.agility
    fill_in "Combat", with: @hero.combat
    fill_in "Cunning", with: @hero.cunning
    fill_in "Health", with: @hero.health
    fill_in "Initiative", with: @hero.initiative
    fill_in "Lore", with: @hero.lore
    fill_in "Luck", with: @hero.luck
    fill_in "Max grit", with: @hero.max_grit
    fill_in "Melee", with: @hero.melee
    fill_in "Name", with: @hero.name
    fill_in "Range", with: @hero.range
    fill_in "Sanity", with: @hero.sanity
    fill_in "Spirit", with: @hero.spirit
    fill_in "Strength", with: @hero.strength
    click_on "Create Hero"

    assert_text "Hero was successfully created"
    click_on "Back"
  end

  test "should update Hero" do
    visit hero_url(@hero)
    click_on "Edit this hero", match: :first

    fill_in "Agility", with: @hero.agility
    fill_in "Combat", with: @hero.combat
    fill_in "Cunning", with: @hero.cunning
    fill_in "Health", with: @hero.health
    fill_in "Initiative", with: @hero.initiative
    fill_in "Lore", with: @hero.lore
    fill_in "Luck", with: @hero.luck
    fill_in "Max grit", with: @hero.max_grit
    fill_in "Melee", with: @hero.melee
    fill_in "Name", with: @hero.name
    fill_in "Range", with: @hero.range
    fill_in "Sanity", with: @hero.sanity
    fill_in "Spirit", with: @hero.spirit
    fill_in "Strength", with: @hero.strength
    click_on "Update Hero"

    assert_text "Hero was successfully updated"
    click_on "Back"
  end

  test "should destroy Hero" do
    visit hero_url(@hero)
    click_on "Destroy this hero", match: :first

    assert_text "Hero was successfully destroyed"
  end
end
