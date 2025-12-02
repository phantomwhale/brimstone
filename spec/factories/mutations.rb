FactoryBot.define do
  factory :mutation do
    association :hero
    sequence(:name) { |n| "Mutation #{n}" }
    description { "A strange mutation" }
    roll { 1 }
    modifiers { {} }

    trait :with_modifiers do
      modifiers { { "strength" => 1, "spirit" => -1 } }
    end

    trait :extra_hands do
      name { "Extra Arm" }
      modifiers { { "total_hands" => 1 } }
    end

    trait :from_chart do
      mutation_key { "extra_arm" }
      name { "Extra Arm" }
      description { "You have grown an extra arm" }
      modifiers { { "total_hands" => 1 } }
    end
  end
end
