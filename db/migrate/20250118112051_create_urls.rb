class CreateUrls < ActiveRecord::Migration[8.0]
  def change
    create_table :urls do |t|
      t.string :original_url, null: false
      t.string :key, null: false
      t.integer :click_count, null: false, default: 0

      t.timestamps
    end
    add_index :urls, :key, unique: true
  end
end
