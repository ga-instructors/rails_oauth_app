Rails.application.routes.draw do
  resources :users
  
  resource :session, only: [:new, :create, :destroy]
  get "/logout", to: "sessions#destroy"
  
  root "sessions#new"
end
