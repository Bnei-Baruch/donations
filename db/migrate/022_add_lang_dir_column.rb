class AddLangDirColumn < ActiveRecord::Migration
  def self.up
	add_column :languages, :direction, :string, :default => "ltr"
  end

  def self.down
	remove_column :languages, :direction
  end
end
