# # == Schema Information
# #
# # Table name: flights
# #
# #  id          :bigint           not null, primary key
# #  name        :string           not null
# #  no_of_seats :integer
# #  base_price  :integer          not null
# #  departs_at  :datetime
# #  arrives_at  :datetime
# #  company_id  :bigint
# #  created_at  :datetime         not null
# #  updated_at  :datetime         not null
# #
# RSpec.describe Flight do
#   subject { flight }
#
#   let(:flight) { create(:flight) }
#
#   it { is_expected.to validate_presence_of(:name) }
#   it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:company_id) }
#
#   it { is_expected.to validate_presence_of(:base_price) }
#   it { is_expected.to validate_numericality_of(:base_price).is_greater_than(0) }
#
#   it { is_expected.to validate_presence_of(:no_of_seats) }
#   it { is_expected.to validate_numericality_of(:no_of_seats).is_greater_than(0) }
#
#   it { is_expected.to validate_presence_of(:departs_at) }
#   it { is_expected.to validate_presence_of(:arrives_at) }
#
#   describe '#departs_at_before_arrives_at' do
#     it 'raises error if departs_at is after arrives_at' do
#       flight.departs_at = Time.zone.now.getutc
#       flight.arrives_at = 1.day.ago
#
#       flight.departs_at_before_arrives_at
#
#       expect(flight.errors[:departs_at]).to include('must be before arrives_at')
#     end
#   end
#
#   describe '#overbook' do
#     it 'raises error if flight seats is smaller than sum of booked seats' do
#       first = create(:booking, no_of_seats: 10)
#       second = create(:booking, no_of_seats: 10)
#       flight = create(:flight, no_of_seats: 19)
#       flight.bookings = [first, second]
#
#       flight.overbook
#
#       expect(flight.errors[:no_of_seats]).to include('flight is overbooked')
#     end
#   end
#
#   it { is_expected.to have_many(:bookings) }
# end
