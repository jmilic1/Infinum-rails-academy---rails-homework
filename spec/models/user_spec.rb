RSpec.describe User do
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_length_of(:first_name).is_at_least(2) }
  it { is_expected.to validate_presence_of(:email) }

  describe 'uniqueness' do
    subject { FactoryBot.create(:user) }

    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end
end
