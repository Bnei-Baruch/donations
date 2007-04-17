class PageContent < ActiveRecord::Base

  belongs_to  :language

  validates_presence_of :main_page
  validates_presence_of :about_page
  validates_presence_of :why_now_page
  validates_presence_of :faq_page
  validates_presence_of :privacy_and_security_page
  validates_presence_of :contact_us_page

  def validate
      errors.add(:language_id, "is missing" ) if language.nil?
  end

  def self.get_page_content_by_lang(lang)
		find_by_language_id( Language.find_by_name(lang) )
  end
end
