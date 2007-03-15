class AddCommonCopyright < ActiveRecord::Migration
  def self.up
	add_column :commons, :copyright, :text, :default => ""
  end

  def self.down
	remove_column :commons, :copyright
  end
end
