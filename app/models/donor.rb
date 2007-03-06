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

  def self.all_approved_donors
	find(:all, :conditions => [ "approved = ?", true])
  end

  protected

  def validate
      errors.add(:payment_id, "is missing" ) if payment.nil?
	#errors.add(:sum_dollars, "should be positive" ) if sum_dollars <= 0
  end

end
