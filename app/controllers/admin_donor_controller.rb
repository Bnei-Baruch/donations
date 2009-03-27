require 'csv'
require 'finance/currency'

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
	@projects  = Project.all_projects_names_completed(nil, false)
  end

  def search_results

    @name_prefix = params['donor']['name'] || ''
    @date        = params['xxxDate'] || ""
    @country     = params['xxxCountry'] || ''
    project_id   = params['xxxProject'] || '0'

    sd   = params['xxxStartDay'].to_i   || 0
    sm   = params['xxxStartMonth'].to_i || 0
    sy   = params['xxxStartYear'].to_i  || 0
    ed   = params['xxxEndDay'].to_i     || 0
    em   = params['xxxEndMonth'].to_i   || 0
    ey   = params['xxxEndYear'].to_i    || 0

	history = params['xxxHistory'] || 'off'
		
    if (@country == "")
      if project_id == '0'
        @donors = Donor.find(:all,
          :conditions => [ "name ILIKE ?", @name_prefix + '%' ],
          :order => 'name ASC')
      else
        @donors = Donor.find(:all,
          :conditions => [ "name ILIKE ? AND project_id = ?", @name_prefix + '%', project_id ],
          :order => 'name ASC')
      end
    else
      if project_id == '0'
        @donors = Donor.find(:all,
          :conditions => [ "name ILIKE ? AND country = ? AND project_id = ? ", @name_prefix + '%', @country, project_id ],
          :order => 'name ASC')
      else
        @donors = Donor.find(:all,
          :conditions => [ "name ILIKE ? AND country = ? ", @name_prefix + '%', @country ],
          :order => 'name ASC')
      end
    end

    if (history == 'on')
	  from_date = Date.new(y=sy, m=sm, d=sd)
	  to_date = Date.new(y=ey, m=em, d=ed)

      @donors.delete_if { |donor| (Date.new(y=donor.created_at.year - 2000, m=donor.created_at.month, d=donor.created_at.day) < from_date ||
								   Date.new(y=donor.created_at.year - 2000, m=donor.created_at.month, d=donor.created_at.day) > to_date) }
    end

    @file_name = 'public/report.csv'
    if File.exist?(@file_name)
      File.delete(@file_name)
    end

    CSV.open(@file_name, 'w') do |writer|

	  total = 0

      writer << ['Name', 'Email', 'Country', 'Date', 'Sum [$]', 'Sum [Original currency]', 'Project'] 
      for donor in @donors
		currency_str = Currency.find(donor.currency_id).name rescue '$'

		sum_in_dollars = 0
		sum_in_dollars = case currency_str
			when '$'   : donor.sum_dollars
			when 'RUB' : Finance::Currency::convert("USD", "RUB", donor.sum_dollars)
			when 'NIS' : Finance::Currency::convert("USD", "ILS", donor.sum_dollars)
			when 'EUR' : Finance::Currency::convert("USD", "EUR", donor.sum_dollars)
			else donor.sum_dollars
		end
		
		day_padd = donor.created_at.day / 10 == 0 ? '0' : ''
		mon_padd = donor.created_at.month / 10 == 0 ? '0' : ''
        writer << [donor.name, 
				   donor.email, 
				   donor.country, 
				   day_padd + donor.created_at.day.to_s + '.' + mon_padd + donor.created_at.month.to_s + '.' + donor.created_at.year.to_s, 
				   sum_in_dollars, 
				   donor.sum_dollars.to_s + ' ' + currency_str, 
				   donor.project.nil? ? 'All projects' : donor.project.short_name]

		total = total + sum_in_dollars
      end 

	  writer << []
	  writer << ['Total Sum', '', '', '', total] 
    end

    if RAILS_ENV == 'development'
      path_don = '/don'
    else
      path_don = '/donations'
    end

    @run_export_window = true
    @file_url = 'http://' + request.env["HTTP_HOST"] + path_don + '/report.csv'

    #render :action => 'search_pay'

  end

  private
  def auto_complete_responder_for_contacts(value)
    @donors = Donor.find(:all, 
						 :conditions => [ "name ILIKE ?", value + '%'], 
						 :order => 'name ASC')
	render :inline => "<%= auto_complete_result @donors, 'name' %>"
  end

end
