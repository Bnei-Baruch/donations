class AddProjectShortName < ActiveRecord::Migration
 def self.up
	add_column :projects, :short_name, :text, :default => ""
  end

  def self.down
	remove_column :projects, :short_name
  end

end
