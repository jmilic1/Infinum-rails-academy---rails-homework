class UserSerializer < Blueprinter::Base
  identifier :id

  fields :first_name, :last_name, :email, :created_at, :updated_at

  association :bookings, blueprint: BookingSerializer
end
