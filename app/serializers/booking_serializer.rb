class BookingSerializer < Blueprinter::Base
  identifier :id

  fields :no_of_seats, :seat_price

  association :projects, blueprint: FlightSerializer
  association :users, blueprint: UserSerializer
end
