# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Subscriptions::ApplyCouponUseCase, type: :use_case do
  let(:subscription) { create(:subscription, unit_price: 100.0) }
  let(:coupon) { create(:coupon, discount_percentage: 20) }
  let(:external_id) { subscription.external_id }
  let(:coupon_code) { coupon.code }

  subject { described_class.new(external_id: external_id, coupon_code: coupon_code).call }

  describe '#call' do
    context 'when subscription is not found' do
      let(:external_id) { 'non-existent-id' }

      it 'returns an error response' do
        expect(subject.success?).to be false
        expect(subject.error).to eq('Subscription not found')
        expect(subject.status).to eq(:not_found)
      end
    end

    context 'when coupon is not found' do
      let(:coupon_code) { 'invalid-code' }

      it 'returns an error response' do
        expect(subject.success?).to be false
        expect(subject.error).to eq('Coupon not found')
        expect(subject.status).to eq(:not_found)
      end
    end

    context 'when payment provider API fails' do
      before do
        allow(Subscriptions::PaymentProviderApiService)
          .to receive(:new)
          .and_return(instance_double(Subscriptions::PaymentProviderApiService, call: failure_response('Payment API failed', :bad_request)))
      end

      it 'returns an error response' do
        expect(subject.success?).to be false
        expect(subject.error).to eq('Payment API failed')
        expect(subject.status).to eq(:bad_request)
      end
    end

    context 'when ApplyCouponService fails' do
      before do
        allow(Subscriptions::PaymentProviderApiService)
          .to receive(:new)
          .and_return(instance_double(Subscriptions::PaymentProviderApiService, call: success_response))

        allow(Subscriptions::ApplyCouponService)
          .to receive(:new)
          .and_return(instance_double(Subscriptions::ApplyCouponService, call: failure_response('Service failed', :unprocessable_entity)))
      end

      it 'returns an error response' do
        expect(subject.success?).to be false
        expect(subject.error).to eq('Service failed')
        expect(subject.status).to eq(:unprocessable_entity)
      end
    end

    context 'when all conditions are met successfully' do
      before do
        allow(Subscriptions::PaymentProviderApiService)
          .to receive(:new)
          .and_return(instance_double(Subscriptions::PaymentProviderApiService, call: success_response))

        allow(Subscriptions::ApplyCouponService)
          .to receive(:new)
          .and_return(instance_double(Subscriptions::ApplyCouponService, call: success_response(subscription: subscription)))
      end

      it 'returns a success response' do
        expect(subject.success?).to be true
        expect(subject.subscription).to eq(subscription)
      end
    end
  end

  private

  def success_response(subscription: nil)
    Subscriptions::ApplyCouponUseCase::Response.new(success?: true, subscription: subscription)
  end

  def failure_response(error, status)
    Subscriptions::ApplyCouponUseCase::Response.new(success?: false, error: error, status: status)
  end
end
