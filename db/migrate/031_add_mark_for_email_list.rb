class AddMarkForEmailList < ActiveRecord::Migration
  def self.up
    add_column :donors, :agree_to_receive_emails, :boolean
  end

  def self.down
    remove_column :donors, :agree_to_receive_emails
  end
end
