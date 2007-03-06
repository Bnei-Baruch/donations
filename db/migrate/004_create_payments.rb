class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
	t.column :name,         :text
	t.column :description,  :text
	t.column :language_id,  :integer
    end
  end

  def self.down
    drop_table :payments
  end
end
