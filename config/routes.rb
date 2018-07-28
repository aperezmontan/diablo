# frozen_string_literal: true

Rails.application.routes.draw do
  resources :pools do
    resources :entries
  end
  resources :users
end
