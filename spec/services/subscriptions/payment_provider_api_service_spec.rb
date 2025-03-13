# frozen_string_literal: true

require 'rails_helper'
require 'webmock/rspec'

RSpec.describe Subscriptions::PaymentProviderApiService, type: :service do
  let(:external_id) { "sub_12345" }
  let(:unit_price) { 89.99 }
  let(:api_url) { "#{ENV.fetch('PAYMENT_PROVIDER_BASE_URL')}/subscriptions/#{external_id}" }

  subject { described_class.new(external_id: external_id, unit_price: unit_price) }

  before do
    stub_request(:post, api_url)
      .with(
        headers: { 'Content-Type' => 'application/json', 'Authorization' => "Bearer #{ENV.fetch('PAYMENT_PROVIDER_API_KEY')}" },
        body: { unit_price: unit_price }.to_json
      )
      .to_return(response_stub)
  end

  describe "#call" do
    context "when the API request is successful" do
      let(:response_stub) { { status: 200, body: "", headers: {} } }

      it "returns a successful response" do
        response = subject.call

        expect(response.success?).to be_truthy
        expect(response.status).to eq(:ok)
        expect(response.error).to be_nil
      end
    end

    context "when the API returns an error" do
      let(:response_stub) { { status: 502, body: "Bad Gateway", headers: {} } }

      it "logs the error and returns a failure response" do
        response = subject.call

        expect(response.success?).to be_falsey
        expect(response.status).to eq(502)
        expect(response.error).to eq("Bad Gateway")
      end
    end
  end
end
