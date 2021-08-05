module Statistics
  class CompanySerializer < Blueprinter::Base
    identifier :id, name: :company_id

    field :total_revenue do |company|
      total_revenue(company)
    end

    field :total_no_of_booked_seats do |company|
      total_no_of_booked_seats(company)
    end

    field :average_price_of_seat do |company|
      total_revenue(company) / total_no_of_booked_seats(company)
    end

    def total_no_of_booked_seats(company)
      company.flights.inject(0) do |acc, flight|
        acc + flight.bookings.inject(0) { |sum, booking| sum + booking.no_of_seats }
      end
    end

    def total_revenue(company)
      company.flights.inject(0) do |acc, flight|
        acc + flight.bookings.inject(0) do |sum, booking|
          sum + booking.seat_price * booking.no_of_seats
        end
      end
    end
  end
end
