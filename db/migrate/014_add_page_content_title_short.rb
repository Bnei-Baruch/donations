class AddPageContentTitleShort < ActiveRecord::Migration
  
  def self.up
    add_column :page_contents, :main_page_short, :text, :default => ""
    add_column :page_contents, :main_page_title, :text, :default => ""
    
    add_column :page_contents, :about_page_short, :text, :default => ""
    add_column :page_contents, :about_page_title, :text, :default => ""

    add_column :page_contents, :why_now_page_short, :text, :default => ""
    add_column :page_contents, :why_now_page_title, :text, :default => ""

    add_column :page_contents, :faq_page_short, :text, :default => ""
    add_column :page_contents, :faq_page_title, :text, :default => ""

    add_column :page_contents, :privacy_and_security_page_short, :text, :default => ""
    add_column :page_contents, :privacy_and_security_page_title, :text, :default => ""
   
    add_column :page_contents, :contact_us_page_short, :text, :default => ""
    add_column :page_contents, :contact_us_page_title, :text, :default => ""
  end

  def self.down
    remove_column :page_contents, :main_page_short
    remove_column :page_contents, :main_page_title

    remove_column :page_contents, :about_page_short
    remove_column :page_contents, :about_page_title

    remove_column :page_contents, :why_now_page_short
    remove_column :page_contents, :why_now_page_title

    remove_column :page_contents, :faq_page_short
    remove_column :page_contents, :faq_page_title

    remove_column :page_contents, :privacy_and_security_page_short
    remove_column :page_contents, :privacy_and_security_page_title

    remove_column :page_contents, :contact_us_page_short
    remove_column :page_contents, :contact_us_page_title
  end
end
