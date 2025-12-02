FactoryBot.define do
  factory :hero do
    sequence(:name) { |n| "Hero #{n}" }
    hero_class { "Gunslinger" }
    health { 12 }
    sanity { 8 }
    agility { 3 }
    cunning { 2 }
    spirit { 2 }
    strength { 2 }
    lore { 2 }
    luck { 2 }
    initiative { 4 }
    range_to_hit { 4 }
    melee_to_hit { 5 }
    combat { 2 }
    max_grit { 2 }
    defense { 4 }
    willpower { 4 }
    corrupt_resist { 0 }
    experience { 0 }
    gold { 0 }
    dark_stone { 0 }
    sidebag_capacity { 5 }
    sidebag_contents { [] }

    trait :with_items do
      after(:create) do |hero|
        create(:item, hero: hero, name: "Revolver", hands_required: 1)
        create(:item, hero: hero, name: "Hat", body_parts: ["head"])
      end
    end

    trait :with_adjustments do
      after(:create) do |hero|
        create(:adjustment, hero: hero, title: "Blessing", modifiers: { "strength" => 1 })
      end
    end

    trait :with_injuries do
      after(:create) do |hero|
        create(:injury, hero: hero, name: "Broken Arm", modifiers: { "strength" => -1 })
      end
    end

    trait :with_madnesses do
      after(:create) do |hero|
        create(:madness, hero: hero, name: "Paranoia", modifiers: { "sanity" => -2 })
      end
    end

    trait :with_mutations do
      after(:create) do |hero|
        create(:mutation, hero: hero, name: "Extra Arm", modifiers: { "total_hands" => 1 })
      end
    end

    trait :with_full_sidebag do
      sidebag_contents { ["Grit", "Grit", "Grit", "Grit", "Grit"] }
    end
  end
end
