class CreateCommons < ActiveRecord::Migration
  def self.up
    create_table :commons do |t|
	t.column :date,   :timestamp
    end
  end

  def self.down
    drop_table :commons
  end
end
