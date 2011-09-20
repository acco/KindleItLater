class AddKindleToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :kindle, :string
  end

  def self.down
    remove_column :users, :kindle
  end
end
