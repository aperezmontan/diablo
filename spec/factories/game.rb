# frozen_string_literal: true

# This will guess the Game class
FactoryBot.define do
  factory :game do
    home_team 0
    away_team 1
    status 0
    pool
  end
end
