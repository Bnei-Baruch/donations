class Payment < ActiveRecord::Base

  belongs_to  :language
  has_many    :donors

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_format_of :name,
 	:with => %r{[A-Z][a-z]*},
 	:message => " -- the first letter must be in uppercase"

  validates_presence_of :description
  validates_presence_of :code
  validates_presence_of :priority
  validates_numericality_of :priority
 
  def self.all_payments_by_lang(lang)
    language = Language.find(:first, :conditions => [ "name = ?", lang]) 
	 find(:all, :conditions => [ "language_id = ?", language.id ], :order => [:priority])
  end

  def self.all_payments_by_lang_sorted(lang)
    language = Language.find(:first, :conditions => [ "name = ?", lang]) 
	 find(:all, :conditions => [ "language_id = ?", language.id ], :order => [:priority]).map { |l| [l.name, l.id] }.sort
  end

  def self.bank_details(lang)
    language = Language.find(:first, :conditions => [ "name = ?", lang]) 
	 find(:first, :conditions => [ "language_id = ? AND code = ?", language.id, "bank_transaction" ])
  end

  def validate
      errors.add(:language_id, "is missing" ) if language.nil?
  end

end
