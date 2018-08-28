# frozen_string_literal: true

# This will guess the Game class
FactoryBot.define do
  factory :game do
    home_team 0
    away_team 1
    week { rand(1.17) }
    year { rand(0..9999) }

    trait :with_pools do
      transient do
        pools_count 2
      end

      after(:create) do |game, evaluator|
        game.pools << create_list(:pool, evaluator.pools_count, week: game.week, year: game.year)
      end
    end
  end
end
