class AddCommonTranzillaUser < ActiveRecord::Migration
  def self.up
	add_column :commons, :tranzilla_user, :text, :default => ""
  end

  def self.down
	remove_column :commons, :tranzilla_user
  end
end
