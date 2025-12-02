FactoryBot.define do
  factory :madness do
    association :hero
    sequence(:name) { |n| "Madness #{n}" }
    description { "A terrible madness" }
    roll { 1 }
    modifiers { {} }
    permanent { false }

    trait :permanent do
      permanent { true }
    end

    trait :with_modifiers do
      modifiers { { "sanity" => -2, "willpower" => -1 } }
    end

    trait :from_chart do
      madness_key { "paranoia" }
      name { "Paranoia" }
      description { "You trust no one" }
      modifiers { { "cunning" => -1 } }
    end
  end
end
