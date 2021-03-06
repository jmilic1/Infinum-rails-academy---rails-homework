Rails.application.routes.draw do
  namespace :api do
    resources :bookings, :companies, :flights, :users, only: [:index, :show, :create, :update, :destroy]
    resources :session, only: [:create]

    delete '/session', to: 'session#destroy'

    namespace :statistics do
      resources :flights, only: [:index]
      resources :companies, only: [:index]
    end
  end
end

