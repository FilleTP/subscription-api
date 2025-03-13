# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscriptions::ApplyCouponService, type: :service do
  let(:subscription) { create(:subscription, unit_price: 100.0, status: Subscription::STATUSES[:done]) }
  let(:coupon) { create(:coupon, discount_percentage: 10, max_redemptions: 5, redemption_count: 0) }

  subject { described_class.new(subscription: subscription, coupon: coupon) }

  describe "#call" do
    context "when the coupon is successfully applied" do
      before do
        allow(Subscriptions::PaymentProviderApiService).to receive(:new).and_return(double(call: success_payment_response))
      end

      let(:success_payment_response) { Subscriptions::PaymentProviderApiService::Response.new(success?: true, status: :ok) }

      it "applies the discount and updates subscription" do
        response = subject.call

        expect(response.success?).to be_truthy
        expect(response.subscription.unit_price).to eq(90.0)
        expect(response.subscription.status).to eq(Subscription::STATUSES[:done])
        expect(coupon.redemption_count).to eq(1)
      end
    end

    context "when coupon max redemptions reached" do
      let(:coupon) { create(:coupon, max_redemptions: 5, redemption_count: 5) }

      it "returns a failure response" do
        response = subject.call

        expect(response.success?).to be_falsey
        expect(response.error).to eq("Coupon cannot be applied: Maximum redemptions reached")
        expect(response.status).to eq(:unprocessable_entity)
      end
    end

    context "when payment provider API fails" do
      before do
        allow(Subscriptions::PaymentProviderApiService).to receive(:new).and_return(double(call: failed_payment_response))
      end

      let(:failed_payment_response) { Subscriptions::PaymentProviderApiService::Response.new(success?: false, error: "Payment API error", status: :bad_gateway) }

      it "fails and marks the subscription as failed" do
        response = subject.call

        expect(response.success?).to be_falsey
        expect(response.error).to eq("Payment API error")
        expect(response.status).to eq(:bad_gateway)
        expect(subscription.status).to eq(Subscription::STATUSES[:failed])
      end
    end

    context "when transaction fails due to validation error" do
      before do
        allow(subscription).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(subscription))
      end

      it "handles the exception and returns a failure response" do
        response = subject.call

        expect(response.success?).to be_falsey
        expect(response.error).to include("Validation failed")
        expect(response.status).to eq(:unprocessable_entity)
      end
    end
  end
end
