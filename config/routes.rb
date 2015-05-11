Rails.application.routes.draw do
  resources :users
  
  resource :session, only: [:create, :destroy]
  get "/logout", to: "sessions#destroy"
  
  root      "welcome#index"
end
