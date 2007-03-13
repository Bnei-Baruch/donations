class CreateEmails < ActiveRecord::Migration
  def self.up
    create_table :emails do |t|
	t.column :name,       	:text	
	t.column :comment,    	:string
	t.column :email,       	:text	
    end
  end

  def self.down
    drop_table :emails
  end
end
