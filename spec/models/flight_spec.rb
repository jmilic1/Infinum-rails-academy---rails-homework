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
RSpec.describe Flight do
  let(:flight) { FactoryBot.create(:flight) }

  describe 'uniqueness' do
    subject { flight }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:company_id) }

    it { is_expected.to validate_presence_of(:base_price) }
    it { is_expected.to validate_numericality_of(:base_price).is_greater_than(0) }

    it { is_expected.to validate_presence_of(:no_of_seats) }
    it { is_expected.to validate_numericality_of(:no_of_seats).is_greater_than(0) }

    it { is_expected.to validate_presence_of(:departs_at) }
    it { is_expected.to validate_presence_of(:arrives_at) }
  end

  describe '#departs_at_before_arrives_at' do
    it 'raises error if departs_at is after arrives_at' do
      flight = described_class.new
      flight.departs_at = Time.zone.now.getutc
      flight.arrives_at = 1.day.ago

      flight.departs_at_before_arrives_at

      expect(flight.errors[:departs_at]).to include('must be before arrives_at')
    end
  end

  it { is_expected.to have_many(:bookings) }
end
