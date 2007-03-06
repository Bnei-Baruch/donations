class CreateDonors < ActiveRecord::Migration
  def self.up
    create_table :donors do |t|
	t.column :name,       	:text	
      t.column :country,    	:string
	t.column :city,    	:string
	t.column :region,    	:string
      t.column :message, 	:text
      t.column :sum_dollars,  :integer 
      t.column :is_anonymous, :boolean
      t.column :payment_id,   :integer
      t.column :created_at,   :timestamp
      t.column :project_id,   :integer
	t.column :ip,           :string
	t.column :approved,     :boolean
	t.column :currency_id,  :integer
	t.column :sum_curr,     :float 
    end
  end

  def self.down
    drop_table :donors
  end
end
