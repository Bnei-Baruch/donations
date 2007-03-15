class Common < ActiveRecord::Base

  belongs_to  :language

  validates_presence_of :copyright

  def self.get_common_by_lang(lang)
    language = Language.find (:first, :conditions => [ "name = ?", lang]) 
	 find(:first, :conditions => [ "language_id = ?", language.id ])
  end

  def self.get_copyright_by_lang(lang)
    get_common_by_lang(lang).copyright
  end

  def self.get_email_by_lang(lang)
    get_common_by_lang(lang).email
  end

  def validate
      errors.add(:language_id, "is missing" ) if language.nil?
  end

end
