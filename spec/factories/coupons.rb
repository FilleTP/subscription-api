# frozen_string_literal: true

FactoryBot.define do
  factory :coupon do
    code { "DISCOUNT10" }
    discount_percentage { 10 }
    max_redemptions { 100 }
    redemption_count { 0 }
  end
end
