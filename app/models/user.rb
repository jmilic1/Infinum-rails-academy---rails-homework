class User < ApplicationRecord
  validates :email, length: { presence: true }
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, format: URI::MailTo::EMAIL_REGEXP

  validates :first_name, length: { presence: true }
  validates :first_name, length: { minimum: 2 }
end
