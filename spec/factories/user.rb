# frozen_string_literal: true

# This will guess the User class
FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "Bruh#{n}" }
    sequence(:email) { |n| "email#{n}@bruh.com" }
    password 'password'
  end
end
