# frozen_string_literal: true

class ApiKey < ActiveRecord::Base
  before_create :generate_unique_key

  private

  def generate_unique_key
    self.key ||= SecureRandom.hex(32)
  end
end
