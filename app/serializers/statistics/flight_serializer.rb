module Statistics
  class FlightSerializer < Blueprinter::Base
    identifier :id, name: :flight_id

    field :revenue do |flight|
      if flight.bookings.nil?
        0
      else
        flight.bookings.inject(0) { |sum, booking| sum + booking.seat_price * booking.no_of_seats }
      end
    end

    field :no_of_booked_seats do |flight|
      booked_seats(flight)
    end

    field :occupancy do |flight|
      occupancy = booked_seats(flight).to_f / flight.no_of_seats
      "#{occupancy * 100}%"
    end

    def self.booked_seats(flight)
      return 0 if flight.bookings.nil?

      flight.bookings.inject(0) { |sum, booking| sum + booking.no_of_seats }
    end
  end
end
