RSpec.describe Booking do
  it { is_expected.to validate_presence_of(:seat_price) }
  it { is_expected.to validate_numericality_of(:seat_price).is_greater_than(0) }

  it { is_expected.to validate_presence_of(:no_of_seats) }
  it { is_expected.to validate_numericality_of(:no_of_seats).is_greater_than(0) }

  it { is_expected.to validate_numericality_of(:departs_at).is_less_than(DateTime.current) }
end
