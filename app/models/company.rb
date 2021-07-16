class Company < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
  validates :name, length: { presence: true }
end
