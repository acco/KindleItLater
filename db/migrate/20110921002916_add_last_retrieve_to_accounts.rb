class AddLastRetrieveToAccounts < ActiveRecord::Migration
  def self.up
    add_column :accounts, :last_retrieve, :datetime
  end

  def self.down
    remove_column :accounts, :last_retrieve
  end
end
