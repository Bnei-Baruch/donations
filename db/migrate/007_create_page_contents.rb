class CreatePageContents < ActiveRecord::Migration
  def self.up
    create_table :page_contents do |t|
	t.column :main_page,   			  :text
	t.column :about_page,   		  :text
	t.column :why_now_page,   		  :text
	t.column :faq_page,  			  :text
	t.column :parivacy_and_security_page, :text
	t.column :contact_us_page,            :text
	t.column :language_id,  		  :integer
    end
  end

  def self.down
    drop_table :page_contents
  end
end
