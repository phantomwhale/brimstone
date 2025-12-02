FactoryBot.define do
  factory :item do
    association :hero
    sequence(:name) { |n| "Item #{n}" }
    description { "A useful item" }
    equipped { false }
    body_parts { [] }
    hands_required { 0 }
    weight { 0 }

    trait :equipped do
      equipped { true }
    end

    trait :one_handed do
      hands_required { 1 }
    end

    trait :two_handed do
      hands_required { 2 }
    end

    trait :head_slot do
      body_parts { ["head"] }
    end

    trait :chest_slot do
      body_parts { ["chest"] }
    end

    trait :multiple_slots do
      body_parts { ["head", "shoulders"] }
    end

    trait :heavy do
      weight { 3 }
    end

    trait :with_modifiers do
      after(:create) do |item|
        create(:adjustment, hero: item.hero, item: item, title: item.name, modifiers: { "strength" => 1, "combat" => 1 })
      end
    end

    factory :weapon do
      name { "Revolver" }
      hands_required { 1 }
      weight { 1 }
    end

    factory :two_handed_weapon do
      name { "Shotgun" }
      hands_required { 2 }
      weight { 2 }
    end

    factory :armor do
      name { "Leather Vest" }
      body_parts { ["chest"] }
      weight { 1 }
    end

    factory :hat do
      name { "Cowboy Hat" }
      body_parts { ["head"] }
      weight { 0 }
    end
  end
end
