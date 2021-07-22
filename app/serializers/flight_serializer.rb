class FlightSerializer < Blueprinter::Base
  identifier :id

  fields :name, :no_of_seats, :base_price, :departs_at, :arrives_at, :created_at, :updated_at

  view :extended do
    association :bookings, blueprint: BookingSerializer
    association :company, blueprint: CompanySerializer
  end
end
