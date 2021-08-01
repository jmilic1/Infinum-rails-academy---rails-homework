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

  validate :departs_at_after_now, :overbook

  def departs_at_after_now
    return if flight.nil? || flight.departs_at > DateTime.current

    errors.add(:flight, 'departure time must be after current time')
  end

  def overbook
    return if no_of_seats.nil? || flight.nil? || no_of_seats < flight.no_of_seats
    return unless flight.invalid?

    errors.add(:no_of_seats, 'this booking has overbooked the flight')
  end
end
