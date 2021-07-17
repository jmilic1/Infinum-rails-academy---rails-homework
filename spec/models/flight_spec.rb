RSpec.describe Flight do
  let(:flight) { FactoryBot.create(:flight) }

  describe 'name presence' do
    subject { flight }

    it { is_expected.to validate_presence_of(:name) }
  end

  describe 'uniqueness' do
    subject { flight }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive.scoped_to(:company_id) }
  end
end
