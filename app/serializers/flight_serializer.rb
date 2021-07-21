class FlightSerializer < Blueprinter::Base
  identifier :id
  field :name
  field :no_of_seats
  field :base_price
  field :departs_at
  field :arrives_at
  association :company
  association :bookings
end
