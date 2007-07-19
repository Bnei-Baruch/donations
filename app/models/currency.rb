class Currency < ActiveRecord::Base
  
  has_many :donors

  def self.all_currencies
	find(:all, :conditions => "true").map { |l| [l.name, l.id] }.sort
  end

  def self.find_currencies_id_by_name(name)
	(find_by_name(name)).id
  end

end
