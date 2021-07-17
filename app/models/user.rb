class User < ApplicationRecord
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: URI::MailTo::EMAIL_REGEXP

  validates :first_name, presence: true,
                         length: { minimum: 2 }
end
