# frozen_string_literal: true

# This will guess the Game class
FactoryBot.define do
  factory :game do
    home_team 0
    away_team 1
    status 0
    week 0
    year 0

    trait :with_pool do
      transient do
        pools_count 2
      end

      after(:create) do |game, evaluator|
        game.pools << create_list(:pool, evaluator.pools_count)
      end
    end
  end
end
