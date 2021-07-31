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
RSpec.describe Booking do
  subject { create(:booking) }

  it { is_expected.to validate_presence_of(:seat_price) }
  it { is_expected.to validate_numericality_of(:seat_price).is_greater_than(0) }
  it { is_expected.to validate_presence_of(:no_of_seats) }
  it { is_expected.to validate_numericality_of(:no_of_seats).is_greater_than(0) }

  describe '#departs_at_after_now' do
    it 'raises error if departs_at is before now' do
      booking = create(:booking)
      flight = create(:flight)
      flight.departs_at = 1.day.ago
      booking.flight = flight

      booking.departs_at_after_now

      expect(booking.errors[:flight]).to include('departure time must be after current time')
    end
  end

  describe '#overbook' do
    it 'raises error if no_of_seats is larger than flight seats' do
      flight = create(:flight, no_of_seats: 9)
      booking = create(:booking, no_of_seats: 10)
      booking.flight = flight

      booking.overbook

      expect(booking.errors[:no_of_seats]).to include('this booking has overbooked the flight')
    end
  end
end
