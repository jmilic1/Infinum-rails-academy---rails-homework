FactoryBot.define do
  factory :flight do
    sequence(:name) { |n| "Zagreb-Split#{n}" }
    departs_at { Time.now.getutc }
    arrives_at { Time.now.getutc }
    base_price { 10 }
  end
end
