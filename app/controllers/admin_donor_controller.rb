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

    @file_name = 'public/report.xls'
    if File.exist?(@file_name)
      File.delete(@file_name)
    end

    open(@file_name, 'w') do |writer|

		writer << 
			'<?xml version="1.0"?>
			<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"
			 xmlns:o="urn:schemas-microsoft-com:office:office"
			 xmlns:x="urn:schemas-microsoft-com:office:excel"
			 xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"
			 xmlns:html="http://www.w3.org/TR/REC-html40">
			 <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">
			  <LastAuthor>Donations Admin</LastAuthor>
			 </DocumentProperties>
			 <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">
			  <DownloadComponents/>
			 </OfficeDocumentSettings>
			 <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">
			  <WindowHeight>9300</WindowHeight>
			  <WindowWidth>15135</WindowWidth>
			  <WindowTopX>120</WindowTopX>
			  <WindowTopY>120</WindowTopY>
			  <AcceptLabelsInFormulas/>
			  <ProtectStructure>False</ProtectStructure>
			  <ProtectWindows>False</ProtectWindows>
			 </ExcelWorkbook>
			 <Styles>
			  <Style ss:ID="Default" ss:Name="Normal">
			   <Alignment ss:Vertical="Bottom"/>
			   <Borders/>
			   <Font/>
			   <Interior/>
			   <NumberFormat/>
			   <Protection/>
			  </Style>
			 </Styles>
			 <Worksheet ss:Name="Sheet1">
			  <Table ss:ExpandedColumnCount="7" ss:ExpandedRowCount="' + (@donors.size + 3).to_s + '" x:FullColumns="1"
			   x:FullRows="1">
			   <Column ss:Index="6" ss:Width="109.5"/>'

		writer << create_donors_xml_entries(@donors)

		writer <<
		  '</Table>
		  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">
		   <Selected/>
		   <ProtectObjects>False</ProtectObjects>
		   <ProtectScenarios>False</ProtectScenarios>
		  </WorksheetOptions>
		 </Worksheet>		 
		</Workbook>'

    end

    if RAILS_ENV == 'development'
      path_don = '/don'
    else
      path_don = '/donations'
    end

    @run_export_window = true
    @file_url = 'http://' + request.env["HTTP_HOST"] + path_don + '/report.xls'

    #render :action => 'search_pay'

  end

  private
  def auto_complete_responder_for_contacts(value)
    @donors = Donor.find(:all, 
						 :conditions => [ "name ILIKE ?", value + '%'], 
						 :order => 'name ASC')
	render :inline => "<%= auto_complete_result @donors, 'name' %>"
  end

  def create_donors_xml_entries(donors)
	
	xml_entries = 
		'<Row>
		<Cell><Data ss:Type="String">Name</Data></Cell>
		<Cell><Data ss:Type="String">Email</Data></Cell>
		<Cell><Data ss:Type="String">Country</Data></Cell>
		<Cell><Data ss:Type="String">Date</Data></Cell>
		<Cell><Data ss:Type="String">Sum [$]</Data></Cell>
		<Cell><Data ss:Type="String">Sum [Original currency]</Data></Cell>
		<Cell><Data ss:Type="String">Project</Data></Cell>
	   </Row>'

	total = 0

	for donor in donors
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
		project  = donor.project.nil? ? 'All projects' : donor.project.short_name
		country  = donor.country.nil? ? 'Unknown' : donor.country
		email    = donor.email.nil? ? '' : donor.email

		xml_entries = xml_entries +	
		'<Row>
		<Cell><Data ss:Type="String">' + donor.name + '</Data></Cell>
		<Cell><Data ss:Type="String">' + email + '</Data></Cell>
		<Cell><Data ss:Type="String">' + country + '</Data></Cell>
		<Cell><Data ss:Type="String">' + day_padd + donor.created_at.day.to_s + '.' + mon_padd + donor.created_at.month.to_s + '.' + donor.created_at.year.to_s + '</Data></Cell>
		<Cell><Data ss:Type="Number">' + sum_in_dollars.to_s + '</Data></Cell>
		<Cell><Data ss:Type="String">' + donor.sum_dollars.to_s + ' ' + currency_str + '</Data></Cell>
		<Cell><Data ss:Type="String">' + project + '</Data></Cell>
	   </Row>'

		total = total + sum_in_dollars
	end 

	xml_entries = xml_entries +
	'<Row ss:Index="' + (donors.size + 3).to_s + '">
	<Cell><Data ss:Type="String">Total Sum</Data></Cell>
	<Cell ss:Index="5"><Data ss:Type="Number">' + total.to_s + '</Data></Cell>
	</Row>' 

	return xml_entries

  end

end
