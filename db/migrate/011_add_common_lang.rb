class AddCommonLang < ActiveRecord::Migration
  def self.up
	add_column :commons, :language_id, :integer, :default => 0
  end

  def self.down
	remove_column :commons, :language_id
  end
end
