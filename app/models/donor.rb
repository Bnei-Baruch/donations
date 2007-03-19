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

  def self.all_approved_donors(is_limit)
	if is_limit
		@entries_num = Common.get_entries_per_page("English")
		find(:all, :conditions => [ "approved = ?", true], :limit => @entries_num)
	else
		find(:all, :conditions => [ "approved = ?", true])
	end
  end

  def self.get_total_sum 
	date = Common.get_date_by_lang("English")
	sum = 0
	donors = find(:all, :conditions => [ "approved  = ? AND created_at > ?", true, date ])
	for donor in donors
		sum += donor.sum_dollars
	end
	return sum
  end

  protected

  def validate
      errors.add(:payment_id, "is missing" ) if payment.nil?
	#errors.add(:sum_dollars, "should be positive" ) if sum_dollars <= 0
  end

end
