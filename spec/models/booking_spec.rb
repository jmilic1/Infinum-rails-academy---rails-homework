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
  describe 'uniqueness' do
    subject { FactoryBot.create(:booking) }

    it { is_expected.to validate_presence_of(:seat_price) }
    it { is_expected.to validate_numericality_of(:seat_price).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:no_of_seats) }
    it { is_expected.to validate_numericality_of(:no_of_seats).is_greater_than(0) }
  end

  describe '#departs_at_after_now' do
    it 'raises error if departs_at is before now' do
      booking = FactoryBot.create(:booking)
      flight = FactoryBot.create(:flight)
      flight.departs_at = 1.day.ago
      booking.flight = flight

      booking.departs_at_after_now

      expect(booking.errors[:flight]).to include('departure time must be after current time')
    end
  end
end
