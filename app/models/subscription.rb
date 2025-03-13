# frozen_string_literal: true

class Subscription < ActiveRecord::Base
  STATUSES = {
    processing: "processing",
    done: "done",
    failed: "failed"
  }.freeze

  belongs_to :plan
  belongs_to :coupon, optional: true

  validates :external_id, :seats, :unit_price, presence: true
  validates :seats, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :unit_price, numericality: { greater_than: 0 }
  enum status: STATUSES, _default: nil
end
