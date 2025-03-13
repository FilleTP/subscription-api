module Subscriptions
  class ApplyCouponService
    private attr_reader :subscription, :coupon, :discounted_price
    Response = Struct.new(:success?, :subscription, :status, :error, keyword_init: true)

    def initialize(subscription:, coupon:, discounted_price:)
      @subscription = subscription
      @coupon = coupon
      @discounted_price = discounted_price
    end

    def call
      if coupon.max_redemptions_reached?
        return failure_response(
          error: "Coupon cannot be applied: Maximum redemptions reached",
          status: :unprocessable_entity,
          )
      end

      ActiveRecord::Base.transaction do
        subscription.update!(coupon: coupon, unit_price: discounted_price)
        coupon.increment!(:redemption_count)
      end

      Response.new(success?: true, subscription: subscription)
    rescue ActiveRecord::RecordInvalid => e
      failure_response("Validation failed: #{e.record.errors.full_messages.join(', ')}", :unprocessable_entity)
    rescue StandardError => e
      failure_response("Unexpected error: #{e.message}", :internal_server_error)
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
        subscription_id: subscription&.id,
        coupon_id: coupon&.id,
      )
    end
  end
end
