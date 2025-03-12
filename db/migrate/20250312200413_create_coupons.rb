class CreateCoupons < ActiveRecord::Migration[7.0]
  def change
    create_table :coupons do |t|
      t.string :code, null: false
      t.decimal :discount_percentage, null: false
      t.integer :max_redemptions, null: false, default: 1
      t.integer :redemption_count, null: false, default: 0

      t.timestamps
    end

    add_index :coupons, :code, unique: true
  end
end
