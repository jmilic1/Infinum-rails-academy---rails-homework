class Booking < ApplicationRecord
  belongs_to :flight
  belongs_to :user

  validates :seat_price, presence: true
  validates :seat_price, numericality: { greater_than: 0 }

  validates :no_of_seats, presence: true
  validates :no_of_seats, numericality: { greater_than: 0 }

  validate :departs_at_after_now
  def departs_at_after_now
    return if flight.departs_at < DateTime.current

    errors.add(:departs_at, 'must be before arrives_at')
  end
end
