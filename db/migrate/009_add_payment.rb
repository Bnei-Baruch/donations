class AddPayment < ActiveRecord::Migration
  def self.up
	add_column :payments, :code, :text
	add_column :payments, :priority, :integer , :default => 0
  end

  def self.down
	remove_column :payments, :code
	remove_column :payments, :priority
  end
end
