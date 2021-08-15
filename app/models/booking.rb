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
class Booking < ApplicationRecord
  belongs_to :flight
  belongs_to :user

  validates :seat_price, presence: true,
                         numericality: { greater_than: 0 }

  validates :no_of_seats, presence: true,
                          numericality: { greater_than: 0 }

  validate :departs_at_after_now, :booking_overbook

  def departs_at_after_now
    return if flight.nil? || flight.departs_at > Time.zone.now

    errors.add(:flight, 'departure time must be after current time')
  end

  # rubocop:disable Metrics
  def booking_overbook
    return if no_of_seats.nil? || flight.nil?

    if id.nil? && no_of_seats == 2 && flight_id == 2 &&
       user_id.nil? && created_at.nil? && updated_at.nil?
      # total_num_of_seats = 9
      # flight.no_of_seats = 10
      # flight.bookings.length = 2
      #
      bookings = Booking.where(flight_id: flight_id)
      total_num_of_seats = bookings.inject(0) { |sum, booking| sum + booking.no_of_seats }
      # total_num_of_seats = flight.bookings.inject(0) { |sum, booking| sum + booking.no_of_seats }
      errors.add(total_num_of_seats)
    end

    # total_num_of_seats = 0

    bookings = Booking.where(flight_id: flight_id)
    total_num_of_seats = bookings.inject(0) { |sum, booking| sum + booking.no_of_seats }
    # if flight.bookings.empty?
    #   bookings = Booking.where(flight_id: flight_id)
    #   total_num_of_seats = bookings.inject(0) { |sum, booking| sum + booking.no_of_seats }
    # else
    #   total_num_of_seats = flight.bookings.inject(0) { |sum, booking| sum + booking.no_of_seats }
    #   # errors.add(total_num_of_seats)
    # end
    # flight.no_of_seats = 10
    # no_of_seats = 4
    return if flight.no_of_seats >= total_num_of_seats

    errors.add(:no_of_seats, 'this booking has overbooked the flight')
  end
  # rubocop:enable Metrics
end
