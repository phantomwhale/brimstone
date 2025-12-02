FactoryBot.define do
  factory :injury do
    association :hero
    sequence(:name) { |n| "Injury #{n}" }
    description { "A painful injury" }
    roll { 1 }
    modifiers { {} }
    permanent { false }

    trait :permanent do
      permanent { true }
    end

    trait :with_modifiers do
      modifiers { { "strength" => -1, "agility" => -1 } }
    end

    trait :from_chart do
      injury_key { "broken_arm" }
      name { "Broken Arm" }
      description { "Your arm is broken" }
      modifiers { { "strength" => -1 } }
    end
  end
end
