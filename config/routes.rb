Rails.application.routes.draw do
  resources :exchange_rates, only: [:index]
end
