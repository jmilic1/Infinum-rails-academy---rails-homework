# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
RSpec.describe Company do
  it { is_expected.to validate_presence_of(:name) }

  describe 'uniqueness' do
    subject { FactoryBot.create(:company) }

    it { is_expected.to validate_uniqueness_of(:name).case_insensitive }
  end

  it { is_expected.to have_many(:flights) }
end
