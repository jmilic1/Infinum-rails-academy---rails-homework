module Statistics
  class FlightSerializer < Blueprinter::Base
    identifier :id, name: :flight_id

    # rubocop:disable Style/SymbolProc
    field :revenue do |flight|
      flight.revenue
    end

    field :no_of_booked_seats do |flight|
      flight.booked_seats
    end
    # rubocop:enable Style/SymbolProc

    field :occupancy do |flight|
      occupancy = flight.occupancy
      "#{occupancy * 100}%"
    end
  end
end
