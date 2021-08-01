# == Schema Information
#
# Table name: flights
#
#  id          :bigint           not null, primary key
#  name        :string           not null
#  no_of_seats :integer
#  base_price  :integer          not null
#  departs_at  :datetime
#  arrives_at  :datetime
#  company_id  :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class FlightSerializer < Blueprinter::Base
  identifier :id

  fields :name, :no_of_seats, :base_price, :departs_at, :arrives_at, :created_at, :updated_at

  field :no_of_booked_seats do |flight|
    flight.bookings.inject(0) { |sum, booking| sum + booking.no_of_seats }
  end

  field :company_name do |flight|
    flight..company.name
  end

  field :current_price do |flight|
    if DateTime.now <= flight.departs_at - 15.days
      flight.base_price
    else
      (15 - (flight.departs_at - DateTime.now)).to_i * flight.base_price + flight.base_price
    end
  end

  view :extended do
    association :bookings, blueprint: BookingSerializer
    association :company, blueprint: CompanySerializer
  end
end
