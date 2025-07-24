require "test_helper"

class HeroesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @hero = heroes(:one)
  end

  test "should get index" do
    get heroes_url
    assert_response :success
  end

  test "should get new" do
    get new_hero_url
    assert_response :success
  end

  test "should create hero" do
    assert_difference("Hero.count") do
      post heroes_url, params: { hero: { agility: @hero.agility, combat: @hero.combat, cunning: @hero.cunning, health: @hero.health, initiative: @hero.initiative, lore: @hero.lore, luck: @hero.luck, max_grit: @hero.max_grit, melee: @hero.melee, name: @hero.name, range: @hero.range, sanity: @hero.sanity, spirit: @hero.spirit, strength: @hero.strength } }
    end

    assert_redirected_to hero_url(Hero.last)
  end

  test "should show hero" do
    get hero_url(@hero)
    assert_response :success
  end

  test "should get edit" do
    get edit_hero_url(@hero)
    assert_response :success
  end

  test "should update hero" do
    patch hero_url(@hero), params: { hero: { agility: @hero.agility, combat: @hero.combat, cunning: @hero.cunning, health: @hero.health, initiative: @hero.initiative, lore: @hero.lore, luck: @hero.luck, max_grit: @hero.max_grit, melee: @hero.melee, name: @hero.name, range: @hero.range, sanity: @hero.sanity, spirit: @hero.spirit, strength: @hero.strength } }
    assert_redirected_to hero_url(@hero)
  end

  test "should destroy hero" do
    assert_difference("Hero.count", -1) do
      delete hero_url(@hero)
    end

    assert_redirected_to heroes_url
  end
end
