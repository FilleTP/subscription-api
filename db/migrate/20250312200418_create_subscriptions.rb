class CreateSubscriptions < ActiveRecord::Migration[7.0]
  def change
    create_table :subscriptions do |t|
      t.string :external_id, null: false
      t.references :plan, null: false, foreign_key: true
      t.integer :seats, null: false, default: 1
      t.decimal :unit_price, null: false
      t.references :coupon, foreign_key: true

      t.timestamps
    end

    add_index :subscriptions, :external_id
  end
end
