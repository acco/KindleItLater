class AddTitleToLineItems < ActiveRecord::Migration
  def self.up
    add_column :line_items, :title, :string
  end

  def self.down
    remove_column :line_items, :title
  end
end
