class Subscription < ActiveRecord::Base
  belongs_to :plan
  belongs_to :coupon, optional: true

  validates :external_id, :seats, :unit_price, presence: true
  validates :seats, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :unit_price, numericality: { greater_than: 0 }
end
