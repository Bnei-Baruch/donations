class Common < ActiveRecord::Base

  belongs_to  :language

  validates_presence_of :copyright
  validates_presence_of :target_sum
  validates_numericality_of :target_sum
  validates_numericality_of :entries_per_page

  def self.get_common_by_lang(lang)
		language = Language.find_by_name(lang)
		find(language.id)
  end

  def self.get_user_by_lang(lang)
    get_common_by_lang(lang).tranzilla_user
  end

  def self.get_copyright_by_lang(lang)
    get_common_by_lang(lang).copyright
  end

  def self.get_email_by_lang(lang)
    get_common_by_lang(lang).email
  end

  def self.get_date_by_lang(lang)
    get_common_by_lang(lang).date
  end

  def self.get_target_sum(lang)
    get_common_by_lang(lang).target_sum
  end

  def self.get_entries_per_page(lang)
    get_common_by_lang(lang).entries_per_page
  end

  def validate
		errors.add(:language_id, "is missing" ) if language.nil?
  end

end
