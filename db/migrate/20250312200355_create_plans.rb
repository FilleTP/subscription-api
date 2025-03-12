class CreatePlans < ActiveRecord::Migration[7.0]
  def change
    create_table :plans do |t|
      t.string :title, null: false
      t.decimal :unit_price, null: false

      t.timestamps
    end
  end
end
