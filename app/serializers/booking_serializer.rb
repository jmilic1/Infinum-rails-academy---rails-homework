# == Schema Information
#
# Table name: bookings
#
#  id          :bigint           not null, primary key
#  no_of_seats :integer
#  seat_price  :integer          not null
#  flight_id   :bigint
#  user_id     :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class BookingSerializer < Blueprinter::Base
  identifier :id

  fields :no_of_seats, :seat_price, :created_at, :updated_at

  # rubocop:disable Style/SymbolProc
  view :extended do
    field :total_price do |booking|
      booking.total_price
    end
    # rubocop:enable Style/SymbolProc

    association :flight, blueprint: FlightSerializer
    association :user, blueprint: UserSerializer
  end
end
