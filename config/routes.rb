Rails.application.routes.draw do
  namespace :api do
    resources :bookings, :companies, :flights, :users
  end
end

