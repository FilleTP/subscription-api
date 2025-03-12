# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Plan, type: :model do
  subject { create(:plan) }
  
  describe "associations" do
    it { should have_many(:subscriptions) }
  end

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_numericality_of(:unit_price).is_greater_than(0) }
  end
end
