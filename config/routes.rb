# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  resources :pools do
    resources :entries
  end
  resources :users_admin, controller: 'users'

  root 'pools#index'
end
