class UserSerializer < Blueprinter::Base
  identifier :id
  field :first_name
  field :last_name
  field :email
  association :bookings
end
