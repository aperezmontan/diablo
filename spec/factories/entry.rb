
# frozen_string_literal: true

# This will guess the Entry class
FactoryBot.define do
  factory :entry do
    name 'This is an Entry'
    status 0
    teams [0, 1, 2, 3, 4, 5]
    pool
    user
  end
end
