# frozen_string_literal: true

module Api
  module V1
    class SubscriptionsController < ApplicationController
      def apply_coupon
        response = Subscriptions::ApplyCouponUseCase.call(
          external_id: params[:external_id],
          coupon_code: params[:coupon_code]
        )

        if response.success?
          render json: { message: 'Coupon applied successfully', subscription: result.subscription }, status: :ok
        else
          render json: { error: result.error }, status: result.status
        end
      end

      def remove_coupon
        response = Subscriptions::RemoveCouponUseCase.call(external_id: params[:external_id])

        if response.success?
          render json: { message: 'Coupon removed successfully', subscription: result.subscription }, status: :ok
        else
          render json: { error: result.error }, status: result.status
        end
      end
    end
  end
end
