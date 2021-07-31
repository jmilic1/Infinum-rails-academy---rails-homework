class BookingSerializer < Blueprinter::Base
  identifier :id

  fields :no_of_seats, :seat_price, :created_at, :updated_at

  view :extended do
    association :flight, blueprint: FlightSerializer
    association :user, blueprint: UserSerializer
  end
end
