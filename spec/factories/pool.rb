# frozen_string_literal: true

# This will guess the Pool class
FactoryBot.define do
  factory :pool do
    week { rand(1.17) }
    year { rand(0..9999) }
    description 'This is a Pool'
  end
end
