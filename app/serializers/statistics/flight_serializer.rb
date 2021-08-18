module Statistics
  class FlightSerializer < Blueprinter::Base
    identifier :id, name: :flight_id

    field :revenue do |flight|
      Flight.revenue(flight)
    end

    field :no_of_booked_seats do |flight|
      Flight.booked_seats(flight)
    end

    field :occupancy do |flight|
      occupancy = Flight.occupancy(flight)
      "#{occupancy * 100}%"
    end
  end
end
