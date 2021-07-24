Rails.application.routes.draw do
  namespace :api do
    resources :bookings, :companies, :flights, :users, only: [:index, :show, :create, :update, :destroy]
    resources :sessions, only: [:create]

    delete '/session', to: 'sessions#delete'
  end
end

