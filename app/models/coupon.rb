class Coupon < ActiveRecord::Base
  has_many :subscriptions, dependent: :nullify

  validates :code, presence: true, uniqueness: true
  validates :discount_percentage, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :max_redemptions, numericality: { only_integer: true, greater_than: 0 }
  validates :redemption_count, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def max_redemptions_reached?
    redemption_count >= max_redemptions
  end
end
