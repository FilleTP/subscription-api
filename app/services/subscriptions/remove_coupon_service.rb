# frozen_string_literal: true

module Subscriptions
  class RemoveCouponService
    private attr_reader :subscription
    Response = Struct.new(:success?, :subscription, :status, :error, keyword_init: true)

    def initialize(subscription:)
      @subscription = subscription
    end

    def call
      if subscription.coupon.nil?
        return failure_response(
          "This subscription does not have any coupon",
          :unprocessable_entity,
          )
      end

      original_price = subscription.plan.unit_price

      ActiveRecord::Base.transaction do
        subscription.update!(
          coupon: nil,
          unit_price: original_price,
          status: Subscription::STATUSES[:processing],
        )
      end

      payment_response = update_payment_provider(original_price)

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

    def update_payment_provider(original_price)
      PaymentProviderApiService.new(
        external_id: subscription.external_id,
        unit_price: original_price,
      ).call
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
      )
    end
  end
end
