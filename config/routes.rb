Rails.application.routes.draw do
  resources :users
  
  resource :session, only: [:new, :create, :destroy]
  get "/logout",         to: "sessions#destroy"
  get "/oauth_callback", to: "sessions#create"
  
  root "sessions#new"
end
