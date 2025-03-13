class AddStatusToSubscriptions < ActiveRecord::Migration[7.0]
  def change
    add_column :subscriptions, :status, :string
    add_index :subscriptions, :status
  end
end
