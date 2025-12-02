FactoryBot.define do
  factory :adjustment do
    association :hero
    sequence(:title) { |n| "Adjustment #{n}" }
    active { true }
    modifiers { { "strength" => 1 } }

    trait :inactive do
      active { false }
    end

    trait :for_item do
      association :item
      title { item&.name || "Item Adjustment" }
    end

    trait :for_injury do
      association :injury
      title { "Injury: #{injury&.name || 'Unknown'}" }
    end

    trait :for_madness do
      association :madness
      title { "Madness: #{madness&.name || 'Unknown'}" }
    end

    trait :for_mutation do
      association :mutation
      title { "Mutation: #{mutation&.name || 'Unknown'}" }
    end

    trait :with_multiple_modifiers do
      modifiers { { "strength" => 2, "agility" => -1, "health" => 3 } }
    end

    trait :empty_modifiers do
      modifiers { {} }
    end
  end
end
