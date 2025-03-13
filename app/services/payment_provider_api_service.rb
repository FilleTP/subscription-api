# frozen_string_literal: true

require 'httparty'

module Subscriptions
  class PaymentProviderApiService
    include HTTParty
    base_uri ENV.fetch('PAYMENT_PROVIDER_BASE_URL')

    private attr_reader :external_id, :unit_price
    Response = Struct.new(:success?, :status, :error, keyword_init: true)

    def initialize(external_id:, unit_price:)
      @external_id = external_id
      @unit_price = unit_price
    end

    def call
      response = self.class.post(
        "/subscriptions/#{external_id}",
        headers: headers,
        body: { unit_price: unit_price }.to_json
      )

      return handle_response(response)
    rescue StandardError => e
      log_error("Unexpected error: #{e.message}", :internal_server_error)
      Response.new(success?: false, error: e.message, status: :internal_server_error)
    end

    private

    def headers
      {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{ENV.fetch('PAYMENT_PROVIDER_API_KEY')}"
      }
    end

    def handle_response(response)
      return Response.new(success?: true, status: :ok) if response.success?

      log_error("Payment provider error: #{response.body}", response.code)
      Response.new(success?: false, error: response.body, status: response.code)
    end

    def log_error(error, status)
      Rails.logger.error(
        error: "#{self.class} - #{error}",
        external_id: external_id,
        unit_price: unit_price,
        status: status
      )
    end
  end
end
