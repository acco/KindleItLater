class AddLastRetrieveToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :last_retrieve, :time
  end

  def self.down
    remove_column :accounts, :last_retrieve
  end
end
