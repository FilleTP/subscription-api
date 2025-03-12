# frozen_string_literal: true

FactoryBot.define do
  factory :subscription do
    external_id { SecureRandom.uuid }
    plan
    seats      { 1 }
    unit_price { 19.99 }

    trait :with_coupon do
      association :coupon
    end
  end
end
