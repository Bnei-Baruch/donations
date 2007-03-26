class Donor < ActiveRecord::Base

  belongs_to :project
  belongs_to :payment
  belongs_to :currency

  validates_presence_of :country
  validates_presence_of :sum_dollars
  validates_numericality_of :sum_dollars

  def self.all_donors
	find(:all)
  end

  def self.all_approved_donors(lang, to_limit)
	if to_limit
		@entries_num = Common.get_entries_per_page(lang)
		find(:all, :conditions => [ "approved = ?", true], :limit => @entries_num, :order => "created_at DESC")
	else
		find(:all, :conditions => [ "approved = ?", true], :order => "created_at DESC")
	end
  end

  def self.get_total_sum (lang)
	date = Common.get_date_by_lang(lang)
	sum = 0
	donors = find(:all, :conditions => [ "approved  = ? AND created_at > ?", true, date ])
	sum = donors.sum {|donor| donor.sum_dollars}
	return sum
  end

  protected

  def validate
      errors.add(:payment_id, "is missing" ) if payment.nil?
	#errors.add(:sum_dollars, "should be positive" ) if sum_dollars <= 0
  end

end
