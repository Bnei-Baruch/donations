class AddProjectFixedSum < ActiveRecord::Migration
  def self.up
	add_column :projects, :fixed_sum, :integer, :default => 0 
  end

  def self.down
	remove_column :projects, :fixed_sum
  end
end
