class AddLanguageShort < ActiveRecord::Migration
  def self.up
	add_column :languages, :short_name, :text, :default => ""
  end

  def self.down
	remove_column :languages, :short_name
  end
end
