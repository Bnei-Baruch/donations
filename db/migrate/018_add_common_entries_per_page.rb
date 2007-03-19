class AddCommonEntriesPerPage < ActiveRecord::Migration
  def self.up
	add_column :commons, :entries_per_page, :integer, :default => 3
  end

  def self.down
	remove_column :commons, :entries_per_page
  end
end
