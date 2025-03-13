# frozen_string_literal: true

FactoryBot.define do
  factory :plan do
    title { "Plan Test" }
    unit_price { 100.0 }
  end
end
