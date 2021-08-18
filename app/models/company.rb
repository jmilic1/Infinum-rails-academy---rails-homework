# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Company < ApplicationRecord
  has_many :flights, dependent: :destroy

  validates :name, uniqueness: { case_sensitive: false }, presence: true

  def self.total_revenue
    flights.inject(0) do |acc, flight|
      acc + flight.bookings.sum do |booking|
        booking.seat_price * booking.no_of_seats
      end
    end
  end

  def self.total_no_of_booked_seats
    flights.inject(0) do |acc, flight|
      acc + flight.bookings.sum(&:no_of_seats)
    end
  end
end
