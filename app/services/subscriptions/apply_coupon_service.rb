# frozen_string_literal: true

module Subscriptions
  class ApplyCouponService
    private attr_reader :subscription, :coupon, :discounted_price
    Response = Struct.new(:success?, :subscription, :status, :error, keyword_init: true)

    def initialize(subscription:, coupon:)
      @subscription = subscription
      @coupon = coupon
    end

    def call
      if coupon.max_redemptions_reached?
        return failure_response(
          "Coupon cannot be applied: Maximum redemptions reached",
          :unprocessable_entity,
          )
      end

      discounted_price = calculate_discount

      ActiveRecord::Base.transaction do
        subscription.update!(
          coupon: coupon,
          unit_price: discounted_price,
          status: Subscription::STATUSES[:processing],
        )
        coupon.increment!(:redemption_count)
      end

      payment_response = update_payment_provider(discounted_price)

      if payment_response.success?
        subscription.update!(status: Subscription::STATUSES[:done])
      else
        subscription.update!(status: Subscription::STATUSES[:failed])
        return payment_response
      end

      Response.new(success?: true, subscription: subscription)
    rescue ActiveRecord::RecordInvalid => e
      failure_response("Validation failed: #{e.record.errors.full_messages.join(', ')}", :unprocessable_entity)
    rescue StandardError => e
      failure_response("Unexpected error: #{e.message}", :internal_server_error)
    end

    private

    def update_payment_provider(discounted_price)
      PaymentProviderApiService.new(
        external_id: subscription.external_id,
        unit_price: discounted_price,
      ).call
    end

    def calculate_discount
      subscription.unit_price * (1 - (coupon.discount_percentage / 100.0))
    end

    def failure_response(error, status)
      log_error(error, status)
      Response.new(success?: false, error: error, status: status)
    end

    def log_error(error, status)
      Rails.logger.error(
        error: "#{self.class} - #{error}",
        status: status,
        subscription_id: subscription.id,
        coupon_id: coupon.id,
      )
    end
  end
end
