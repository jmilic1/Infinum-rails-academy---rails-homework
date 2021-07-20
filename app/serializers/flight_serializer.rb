class UserSerializer < Blueprinter::Base
  identifier :id
  field :name
  field :no_of_seats
  field :base_price
  field :departs_at
  field :arrives_at
  field :company_id
  association :company
  association :bookings
end
