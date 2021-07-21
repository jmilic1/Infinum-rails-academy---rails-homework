# == Schema Information
#
# Table name: users
#
#  id         :bigint           not null, primary key
#  first_name :string
#  last_name  :string
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
RSpec.describe User do
  it { is_expected.to validate_presence_of(:first_name) }
  it { is_expected.to validate_length_of(:first_name).is_at_least(2) }
  it { is_expected.to validate_presence_of(:email) }

  describe 'uniqueness' do
    subject { FactoryBot.create(:user) }

    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  it { is_expected.to allow_value('korisnik@email.com').for(:email) }
  it { is_expected.not_to allow_value('korisnik@').for(:email) }
  it { is_expected.not_to allow_value('korisnikemail.com').for(:email) }
  it { is_expected.not_to allow_value('@email.com').for(:email) }

  it { is_expected.to have_many(:bookings) }
end
