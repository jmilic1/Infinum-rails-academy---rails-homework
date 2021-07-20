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
FactoryBot.define do
  factory :flight do
    sequence(:name) { |n| "Zagreb-Split#{n}" }
    departs_at { 1.day.ago }
    arrives_at { Time.zone.now.getutc }
    base_price { 10 }
    company { create(:company) }
  end
end
