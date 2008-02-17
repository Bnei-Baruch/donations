class AdminDonorController < ApplicationController

  layout 'admin'

  before_filter :authorize

  auto_complete_for :donor, :name
  def auto_complete_for_donor_name
    auto_complete_responder_for_contacts params["donor"]["name"]
  end

  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @donor_pages, @donors = paginate :donors, :per_page => 10, :order => "created_at DESC"
  end

  def show
    @donor = Donor.find(params[:id])
  end

  def new
    @donor = Donor.new
  end

  def create
    @donor = Donor.new(params[:donor])
    if @donor.save
      flash[:notice] = 'Donor was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @donor = Donor.find(params[:id])
  end

  def update
    @donor = Donor.find(params[:id])
    if @donor.update_attributes(params[:donor])
      flash[:notice] = 'Donor was successfully updated.'
      redirect_to :action => 'show', :id => @donor
    else
      render :action => 'edit'
    end
  end

  def destroy
    Donor.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def search_pay
    donors = Donor.find(:all)
	
	@countries = ((Array.new(donors.size) { |i| donors[i].country }).uniq).sort
	@dates     = ((Array.new(donors.size) { |i| donors[i].created_at.to_date}).uniq).sort
	#@amounts   = ((Array.new(donors.size) { |i| donors[i].sum_curr }).uniq).sort
  end

  def search_results

	@name_prefix = params['donor']['name'] || ""
	@date        = params['xxxDate'] || ""
	@country     = params['xxxCountry'] || ""
		
	if (@country == "")
		@donors = Donor.find(:all, 
							 :conditions => [ "name ILIKE ?", @name_prefix + '%' ], 
							 :order => 'name ASC')
	else
		@donors = Donor.find(:all, 
							 :conditions => [ "name ILIKE ? AND country = ? ", @name_prefix + '%', @country ], 
							 :order => 'name ASC')
	end

	if (@date != "")
		@donors.delete_if { |donor| (donor.created_at.to_date.to_s != @date) }
	end

  end

  private
  def auto_complete_responder_for_contacts(value)
    @donors = Donor.find(:all, 
						 :conditions => [ "name ILIKE ?", value + '%'], 
						 :order => 'name ASC')
	render :inline => "<%= auto_complete_result @donors, 'name' %>"
  end

end
