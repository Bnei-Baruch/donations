class Currency < ActiveRecord::Base
  
  has_many :donors

  def self.all_currencies
	find(:all, :conditions => "true").map { |l| [l.name, l.id] }.sort
  end

end
