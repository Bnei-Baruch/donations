class AddProjectOrderPlus < ActiveRecord::Migration
  def self.up
	add_column :projects, :priority, :integer, :default => 0
	add_column :projects, :url, :text, :default => ""
	add_column :projects, :screenshot, :text, :default => ""	
  end

  def self.down
	remove_column :projects, :priority
	remove_column :projects, :url
	remove_column :projects, :screenshot
  end
end
