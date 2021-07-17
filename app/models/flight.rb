class Flight < ApplicationRecord
  belongs_to :company

  validates :name, uniqueness: { case_sensitive: false, scope: company_id },
                   presence: true

  validates :base_price, presence: true,
                         numericality: { greater_than: 0 }

  validates :departs_at, presence: true
  validates :arrives_at, presence: true

  validate :departs_at_before_arrives_at
  def departs_at_before_arrives_at
    return if departs_at < arrives_at

    errors.add(:departs_at, 'must be before arrives_at')
  end
end