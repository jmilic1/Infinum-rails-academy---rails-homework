FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user-#{n}@email.com" }
    first_name { 'User' }
  end
end
