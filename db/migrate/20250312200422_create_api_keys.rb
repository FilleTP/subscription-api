class CreateApiKeys < ActiveRecord::Migration[7.0]
  def change
    create_table :api_keys do |t|
      t.string :key, null: false
      t.string :name, null: false

      t.timestamps
    end

    add_index :api_keys, :key, unique: true
  end
end
