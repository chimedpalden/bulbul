Rails.application.routes.draw do
  root to: "asks#index"
  resources :asks, only: %i[index create]
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
