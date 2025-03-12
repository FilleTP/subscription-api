class Plan < ActiveRecord::Base
  has_many :subscriptions
  
  validates :title, :unit_price, presence: true
  validates :unit_price, numericality: { greater_than: 0 }
end
