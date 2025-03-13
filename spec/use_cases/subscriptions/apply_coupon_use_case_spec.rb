# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscriptions::ApplyCouponUseCase, type: :use_case do
  let(:subscription) { create(:subscription, external_id: "sub-123", unit_price: 100.0) }
  let(:coupon) { create(:coupon, code: "DISCOUNT10", discount_percentage: 10) }

  subject { described_class.new(external_id: external_id, coupon_code: coupon_code) }

  describe "#call" do
    context "when subscription is not found" do
      let(:external_id) { "nonexistent" }
      let(:coupon_code) { coupon.code }

      it "returns a failure response with not_found status" do
        response = subject.call

        expect(response.success?).to be_falsey
        expect(response.error).to eq("Subscription not found")
        expect(response.status).to eq(:not_found)
      end
    end

    context "when coupon is not found" do
      let(:external_id) { subscription.external_id }
      let(:coupon_code) { "INVALIDCODE" }

      it "returns a failure response with not_found status" do
        response = subject.call

        expect(response.success?).to be_falsey
        expect(response.error).to eq("Coupon not found")
        expect(response.status).to eq(:not_found)
      end
    end

    context "when ApplyCouponService fails" do
      let(:external_id) { subscription.external_id }
      let(:coupon_code) { coupon.code }

      before do
        allow(Subscriptions::ApplyCouponService).to receive(:new).and_return(double(call: service_response))
      end

      context "when service fails with validation error" do
        let(:service_response) { Subscriptions::ApplyCouponService::Response.new(success?: false, error: "Validation failed", status: :unprocessable_entity) }

        it "returns a failure response" do
          response = subject.call

          expect(response.success?).to be_falsey
          expect(response.error).to eq("Validation failed")
          expect(response.status).to eq(:unprocessable_entity)
        end
      end
    end

    context "when ApplyCouponService succeeds" do
      let(:external_id) { subscription.external_id }
      let(:coupon_code) { coupon.code }

      before do
        allow(Subscriptions::ApplyCouponService).to receive(:new).and_return(double(call: service_response))
      end

      let(:service_response) { Subscriptions::ApplyCouponService::Response.new(success?: true, subscription: subscription) }

      it "returns a success response" do
        response = subject.call

        expect(response.success?).to be_truthy
        expect(response.subscription).to eq(subscription)
      end
    end
  end
end
