class CreateProjects < ActiveRecord::Migration
  def self.up
    create_table :projects do |t|
 	t.column :name,         :text
	t.column :short_decr,   :text
      t.column :description,  :text
      t.column :cost,         :integer 
      t.column :is_completed, :boolean
	t.column :start_date,   :timestamp
	t.column :duration,     :timestamp
	t.column :donor_id,     :integer
	t.column :language_id,  :integer
    end
  end

  def self.down
    drop_table :projects
  end
end
