class AddCommonTotalSum < ActiveRecord::Migration
  def self.up
	add_column :commons, :target_sum, :integer, :default => 0 
  end

  def self.down
	remove_column :commons, :target_sum
  end
end
