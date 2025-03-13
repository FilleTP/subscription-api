# frozen_string_literal: true

module Subscriptions
  class ApplyCouponUseCase
    private attr_reader :external_id, :coupon_code
    Response = Struct.new(:success?, :subscription, :error, :status, keyword_init: true)

    def initialize(external_id:, coupon_code:)
      @external_id = external_id
      @coupon_code = coupon_code
    end

    def call
      subscription = Subscription.find_by(external_id: external_id)
      return failure_response('Subscription not found', :not_found) unless subscription

      coupon = Coupon.find_by(code: coupon_code)
      return failure_response('Coupon not found', :not_found) unless coupon

      service_response = ApplyCouponService.new(
        subscription: subscription,
        coupon: coupon,
      ).call

      return failure_response(service_response.error, service_response.status) unless service_response.success?

      Response.new(success?: true, subscription: service_response.subscription)
    end

    private

    def failure_response(error, status)
      log_error(error, status)
      Response.new(success?: false, error: error, status: status)
    end

    def log_error(error, status)
      Rails.logger.error(
        error: "#{self.class} - #{error}",
        status: status,
        external_id: external_id,
        coupon_code: coupon_code,
      )
    end
  end
end
