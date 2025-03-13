# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscriptions::RemoveCouponUseCase, type: :use_case do
  let(:subscription) { create(:subscription, external_id: "sub-123", unit_price: 90.0, coupon: coupon) }
  let(:coupon) { create(:coupon, code: "DISCOUNT10", discount_percentage: 10) }

  subject { described_class.new(external_id: external_id) }

  describe "#call" do
    context "When subscription is not found" do
      let(:external_id) { "nonexistent" }

      it "returns a failure response with not_found status" do
        response = subject.call

        expect(response.success?).to be_falsey
        expect(response.error).to eq("Subscription not found")
        expect(response.status).to eq(:not_found)
      end
    end

    context "When RemoveCouponService fails" do
      let(:external_id) { subscription.external_id }

      before do
        allow(Subscriptions::RemoveCouponService).to receive(:new).and_return(double(call: service_response))
      end

      context "when service fails with validation error" do
        let(:service_response) { Subscriptions::RemoveCouponService::Response.new(success?: false, error: "Validation failed", status: :unprocessable_entity) }

        it "returns a failure response" do
          response = subject.call

          expect(response.success?).to be_falsey
          expect(response.error).to eq("Validation failed")
          expect(response.status).to eq(:unprocessable_entity)
        end
      end

    end

    context "When RemoveCouponService succeeds" do
      let(:external_id) { subscription.external_id }

      before do
        allow(Subscriptions::RemoveCouponService).to receive(:new).and_return(double(call: service_response))
      end

      let(:service_response) { Subscriptions::RemoveCouponService::Response.new(success?: true, subscription: subscription) }

      it "returns a success response" do
        response = subject.call

        expect(response.success?).to be_truthy
        expect(response.subscription).to eq(subscription)
      end
    end
  end
end
