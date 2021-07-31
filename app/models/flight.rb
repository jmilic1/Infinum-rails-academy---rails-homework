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

  def departs_at_before_arrives_at
    return if departs_at.nil? || arrives_at.nil? || departs_at < arrives_at

    errors.add(:departs_at, 'must be before arrives_at')
  end

  def overbook
    return if bookings.inject(0) { |sum, booking| sum + booking.no_of_seats} <= no_of_seats

    errors.add(:no_of_seats, 'flight is overbooked')
  end
end
