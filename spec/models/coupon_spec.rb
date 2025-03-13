# frozen_string_literal: true

require 'rails_helper'


RSpec.describe Coupon, type: :model do
  subject { create(:coupon) }

  it { should validate_presence_of(:code) }
  it { should validate_uniqueness_of(:code) }
  it { should validate_numericality_of(:discount_percentage).is_greater_than_or_equal_to(0).is_less_than_or_equal_to(100) }
  it { should validate_numericality_of(:max_redemptions).only_integer.is_greater_than(0) }
  it { should validate_numericality_of(:redemption_count).only_integer.is_greater_than_or_equal_to(0) }

  describe "when associated with a subscription" do
    let(:plan) { create(:plan, unit_price: 100) }
    let!(:subscription) { create(:subscription, plan: plan, coupon: subject) }

    it "does not allow updates and raises an error" do
      expect { subject.update!(discount_percentage: 50) }
        .to raise_error(ActiveRecord::RecordNotSaved, /Failed to save the record/)
    end
  end
end
