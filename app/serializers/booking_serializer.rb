class UserSerializer < Blueprinter::Base
  identifier :id
  field :no_of_seats
  field :seat_price
  association :flight
  association :user
end
