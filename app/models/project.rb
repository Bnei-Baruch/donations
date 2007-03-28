class Project < ActiveRecord::Base

  belongs_to  :language
  has_many    :donors

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :short_decr
  validates_presence_of :description
  validates_presence_of :cost, :only_integer => true, :allow_nil => false
  validates_numericality_of :cost
  validates_presence_of :start_date
  validates_presence_of :duration

  def self.all_projects
	find(:all, :conditions => "true").map { |l| [l.name, l.id] }.sort
  end

  def self.all_completed_projects(lang, is_completed, is_limit)
	language = Language.find(:first, :conditions => ["name = ?", lang])
	if not language.nil?
		if is_limit
			@entries_num = Common.get_entries_per_page(lang)
			find(:all, :conditions => [ "language_id = ? AND is_completed = ?", language.id, is_completed ], :limit => @entries_num, :order => 'priority')
		else
			find(:all, :conditions => [ "language_id = ? AND is_completed = ?", language.id, is_completed ], :order => 'priority')
		end
      end
  end

  protected

  def validate
      errors.add(:language_id, "is missing" ) if language.nil?
  end

end
