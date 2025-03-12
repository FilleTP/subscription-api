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
      subscription = Subscription.find(external_id: external_id)

      unless subscription
        log_error('Subscription not found', :not_found)
        return Response.new(success?: false, error: 'Subscription not found', status: :not_found)
      end

      coupon = Coupon.find_by(code: coupon_code)

      unless coupon
        log_error('Coupon not found', :not_found)
        return Response.new(success?: false, error: 'Coupon not found', status: :not_found)
      end
    end

    private

    def log_error(message, status)
      Rails.logger.error(
        message: "#{self.class} - #{message}",
        status: status,
        external_id: external_id,
        coupon_code: coupon_code,
      )
    end
  end
end
