module Subscriptions
  class ApplyCouponService
    private attr_reader :subscription, :coupon
    Response = Struct.new(:success?, :status, keyword_init: true)

    def initialize(subscription:, coupon:)
      @subscription = subscription
      @coupon = coupon
    end

    def call
      if coupon.max_redemptions_reached?
        return Response.new(success?: false, error: "Coupon cannot be applied: Maximum redemptions reached")
      end

      ActiveRecord::Base.transaction do
        discounted_price = calculate_discount

        subscription.update!(coupon: coupon, unit_price: discounted_price)

        coupon.increment!(:redemption_count)
      end

      Result.new(success?: true, subscription: subscription)
    rescue ActiveRecord::RecordInvalid => e
      log_error("Validation failed: #{e.record.errors.full_messages.join(', ')}", :unprocessable_entity)
    rescue StandardError => e
      log_error("Unexpected error: #{e.message}", :internal_server_error)
    end

    private

    def calculate_discount
      subscription.unit_price * (1 - (coupon.discount_percentage / 100.0))
    end

    def log_error(message, status)
      Rails.logger.error("#{self.class} - #{message}")
      Response.new(success?: false, error: message, status: status)
    end
  end
end
