module Statistics
  class FlightSerializer < Blueprinter::Base
    identifier :id

    field :revenue do |flight|
      if flight.bookings.nil?
        0
      else
        flight.bookings.inject(0) { |sum, booking| sum + booking.seat_price * booking.no_of_seats }
      end
    end

    field :no_of_booked_seats do |flight|
      if flight.bookings.nil?
        0
      else
        flight.bookings.inject(0) { |sum, booking| sum + booking.no_of_seats }
      end
    end

    field :occupancy do |flight|
      booked_seats = 0
      unless flight.bookings.nil?
        booked_seats = flight.bookings.inject(0) { |sum, booking| sum + booking.no_of_seats }
      end

      occupancy = booked_seats / flight.no_of_seats
      "#{occupancy.to_f}%"
    end
  end
end
