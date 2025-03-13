# frozen_string_literal: true

module Subscriptions
  class RemoveCouponUseCase
    private attr_reader :external_id
    Response = Struct.new(:success?, :subscription, :error, :status, keyword_init: true)

    def initialize(external_id:)
      @external_id = external_id
    end

    def call
      subscription = Subscription.find_by(external_id: external_id)
      return failure_response('Subscription not found', :not_found) unless subscription

      service_response = RemoveCouponService.new(
        subscription: subscription,
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
      )
    end
  end
end
