class AddPaymentShort < ActiveRecord::Migration
  def self.up
	add_column :payments, :short_description, :text, :default => ""
  end

  def self.down
	remove_column :payments, :short_description
  end
end
