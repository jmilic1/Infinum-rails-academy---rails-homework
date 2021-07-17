RSpec.describe Company do
  it { is_expected.to validate_presence_of(:name) }

  describe 'uniqueness' do
    subject { FactoryBot.create(:company) }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end
end
