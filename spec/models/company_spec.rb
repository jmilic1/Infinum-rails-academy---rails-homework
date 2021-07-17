RSpec.describe Company, type: model do
  it { is_expected.to validate_presence_of(:name) }

  describe 'uniqueness' do
    subject { described_class.new(name: 'infinum') }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end
end
