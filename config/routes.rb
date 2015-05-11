Rails.application.routes.draw do
  resources :users
  resource  :session, only: [:create, :destroy]
  root      "welcome#index"
end
