# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  first_name      :string
#  last_name       :string
#  email           :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string
#  token           :string
#  role            :string
#
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user-#{n}@email.com" }
    sequence(:password_digest) { |n| "password-#{n}" }
    first_name { 'User' }
  end
end
