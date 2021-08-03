module Statistics
  class FlightSerializer < Blueprinter::Base
    identifier :id

    field :revenue do |flight|
      flight.bookings.inject(0) { |sum, booking| sum + booking.seat_price * booking.no_of_seats }
    end

    field :no_of_booked_seats do |flight|
      no_of_booked_seats(flight)
    end

    field :occupancy do |flight|
      no_of_booked_seats / flight.no_of_seats
    end

    def no_of_booked_seats(flight)
      flight.bookings.inject(0) { |sum, booking| sum + booking.no_of_seats }
    end
  end
end
