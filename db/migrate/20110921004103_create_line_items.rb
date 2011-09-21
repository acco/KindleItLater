class CreateLineItems < ActiveRecord::Migration
  def self.up
    create_table :line_items do |t|
      t.string :url
      t.integer :account_id
      t.boolean :sent

      t.timestamps
    end
  end

  def self.down
    drop_table :line_items
  end
end
