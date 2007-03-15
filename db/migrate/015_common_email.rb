class CommonEmail < ActiveRecord::Migration
  def self.up
	add_column :commons, :email, :text, :default => ""
  end

  def self.down
	remove_column :commons, :email
  end
end
