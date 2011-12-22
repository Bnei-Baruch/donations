class AddFieldToCommons < ActiveRecord::Migration
  def self.up
    add_column :commons, :kabcoil, :text
  end

  def self.down
    remove_column :commons, :kabcoil
  end
end
