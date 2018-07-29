# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }
  resources :pools do
    resources :entries
  end
  resources :users

  root 'pools#index'
end
