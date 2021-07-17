FactoryBot.define do
  factory :company do
    sequence(:name) { |n| "Zagreb - Split#{n}" }
  end
end
