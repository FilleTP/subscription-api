# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  subject { create(:subscription) }

  describe "associations" do
    it { should belong_to(:plan) }
    it { should belong_to(:coupon).optional }
  end

  describe "validations" do
    it { should validate_presence_of(:external_id) }
    it { should validate_presence_of(:seats) }
    it { should validate_numericality_of(:seats).only_integer.is_greater_than_or_equal_to(1) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_numericality_of(:unit_price).is_greater_than(0) }
  end
end
