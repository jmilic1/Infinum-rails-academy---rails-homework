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

  view :extended do
    field :no_of_booked_seats do |flight|
      flight.bookings.inject(0) { |sum, booking| sum + booking.no_of_seats }
    end

    field :company_name do |flight|
      flight.company.name
    end

    field :current_price do |flight|
      difference = (flight.departs_at - Time.zone.now).day
      if difference > 15
        flight.base_price
      elsif difference.negative?
        2 * flight.base_price
      else
        (1 + difference.day.to_f / 15) * flight.base_price
      end
    end

    association :bookings, blueprint: BookingSerializer
    association :company, blueprint: CompanySerializer
  end
end
