class AddAuthToAccount < ActiveRecord::Migration
  def self.up
    add_column :accounts, :auth, :boolean
  end

  def self.down
    remove_column :accounts, :auth
  end
end
