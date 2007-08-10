class AddDonorAcked < ActiveRecord::Migration
  def self.up
	add_column :donors, :acked, :boolean, :default => false
  end

  def self.down
	remove_column :donors, :acked
  end
end
