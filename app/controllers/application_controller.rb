# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authenticate_api_key!

  private

  def authenticate_api_key!
    provided_key = request.headers["Authorization"]

    unless ApiKey.exists?(key: provided_key)
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
