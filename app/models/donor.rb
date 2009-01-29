class Donor < ActiveRecord::Base

  belongs_to :project
  belongs_to :payment
  belongs_to :currency

  validates_presence_of :sum_dollars
  validates_numericality_of :sum_dollars

  def self.all_donors
	find(:all)
  end

  def self.get_total_sum (appr)
	find_all_by_approved(appr).sum {|donor| donor.sum_dollars}
  end

  def self.get_donors_per_project (approved, acked, project_id, sort_col = 'id', sort_order = 'desc')
	donors = find(:all, :conditions => [ "(approved = ? OR acked = ?) AND project_id = ?", approved, acked, project_id ], :order => "#{sort_col} #{sort_order}")
  end

  protected

  def validate
      errors.add(:payment_id, "is missing" ) if payment.nil?
	#errors.add(:sum_dollars, "should be positive" ) if sum_dollars <= 0
  end

end
