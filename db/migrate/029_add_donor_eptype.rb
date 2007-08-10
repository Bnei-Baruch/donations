class AddDonorEptype < ActiveRecord::Migration
  def self.up
	add_column :donors, :is_new, :boolean, :default => false
	add_column :donors, :eptype, :text, :default => ""
  end

  def self.down
	remove_column :donors, :is_new
	remove_column :donors, :eptype
  end
end
