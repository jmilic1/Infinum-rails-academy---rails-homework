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
class Flight < ApplicationRecord
  belongs_to :company
  has_many :bookings, dependent: :destroy

  validates :name, uniqueness: { case_sensitive: false, scope: :company_id },
                   presence: true

  validates :base_price, presence: true,
                         numericality: { greater_than: 0 }

  validates :no_of_seats, presence: true,
                          numericality: { greater_than: 0 }

  validates :departs_at, presence: true
  validates :arrives_at, presence: true

  validate :departs_at_before_arrives_at
  validate :overlap?

  def departs_at_before_arrives_at
    return if departs_at.nil? || arrives_at.nil? || departs_at < arrives_at

    errors.add(:departs_at, 'must be before arrives_at')
  end

  def overlap?
    return if company.nil?

    Flight.where(company_id: company_id).find_each do |flight|
      next if flight.id == id

      if within_flight_range(departs_at, flight) || within_flight_range(arrives_at, flight)
        errors.add(:departs_at, 'departure time overlaps with another flight')
        errors.add(:arrives_at, 'arrival time overlaps with another flight')
      end
    end
  end

  def current_price
    difference = (departs_at - Time.zone.now).to_i / 1.day
    if difference >= 15
      base_price
    elsif difference <= 0
      2 * base_price
    else
      ((2 - difference.to_f / 15) * base_price).round
    end
  end

  def revenue
    bookings&.sum { |booking| booking.seat_price * booking.no_of_seats }
  end

  def booked_seats
    return 0 if bookings.nil?

    bookings.sum(&:no_of_seats)
  end

  def occupancy
    booked_seats.to_f / no_of_seats
  end

  private

  def within_flight_range(moment, flight)
    (moment >= flight.departs_at) && (moment <= flight.arrives_at)
  end
end
