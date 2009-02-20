class Project < ActiveRecord::Base

  belongs_to  :language
  has_many    :donors

  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :short_name
  validates_uniqueness_of :short_name
  validates_presence_of :short_decr
  validates_presence_of :description
  validates_presence_of :cost, :only_integer => true, :allow_nil => false
  validates_numericality_of :cost
  validates_presence_of :start_date
  validates_presence_of :duration
  validates_presence_of :url => ""
  validates_presence_of :screenshot => ""

  def self.all_projects
		find_all().map { |l| [l.name, l.id] }.sort
  end

  def self.all_projects_names(lang)
	
	language = Language.find_by_name(lang)
	if not language.nil?
		(find(:all,  :conditions => [ "language_id = ?", language.id])).map { |l| [l.short_name, l.id] }.sort
	end
  end

  def self.all_projects_names_completed(lang, is_completed)
	
	language = Language.find_by_name(lang)
	if not language.nil?
		(find(:all,  :conditions => [ "language_id = ? AND is_completed = ?", language.id, is_completed])).map { |l| [l.short_name, l.id] }.sort
	end
  end

  def self.all_completed_projects(lang, is_completed, is_limit)
		language = Language.find_by_name(lang)
		if not language.nil?
			if is_limit
				@entries_num = Common.get_entries_per_page(lang)
				find(:all, :conditions => [ "language_id = ? AND is_completed = ?", language.id, is_completed ], :limit => @entries_num, :order => 'priority')
			else
				find_all_by_language_id_and_is_completed(language.id, is_completed, 'priority')
			end
    end
  end

  protected

  def validate
      errors.add(:language_id, "is missing" ) if language.nil?
  end

end
