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
    # rubocop:disable Style/SymbolProc
    field :no_of_booked_seats do |flight|
      flight.booked_seats
    end

    field :current_price do |flight|
      flight.current_price
    end
    # rubocop:enable Style/SymbolProc

    field :company_name do |flight|
      flight.company.name
    end

    association :bookings, blueprint: BookingSerializer
    association :company, blueprint: CompanySerializer
  end
end
