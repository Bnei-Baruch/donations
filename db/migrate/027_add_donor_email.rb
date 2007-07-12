class AddDonorEmail < ActiveRecord::Migration
  def self.up
	add_column :donors, :email, :text, :default => ""
  end

  def self.down
	remove_column :donors, :email
  end
end
