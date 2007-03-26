class Language < ActiveRecord::Base
  
  has_many :payments
  has_many :contents
  has_many :commons

  validates_presence_of :name
  validates_presence_of :short_name
  validates_uniqueness_of :name
  validates_format_of :name,
 	:with => %r{[A-Z][a-z]*},
 	:message => " -- the first letter must be in uppercase"

  def self.all_langs
	find(:all, :conditions => "true").map { |l| [l.name, l.id] }.sort
  end
end
