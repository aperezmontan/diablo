# frozen_string_literal: true

# This will guess the Pool class
FactoryBot.define do
  factory :pool do
    week { rand(1.17) }
    year { rand(0..9999) }
    description 'This is a Pool'

    trait :with_games do
      transient do
        games_count 16
      end

      after(:create) do |pool, evaluator|
        pool.games << create_list(:game, evaluator.games_count)
      end
    end
  end
end
