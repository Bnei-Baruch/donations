require 'cgi'

class UserController < ApplicationController

  layout 'user'

  #before_filter :set_params

  def main
	set_params
  end

  def index
	set_params
  end

  def about
	 set_params
  end

  def why_now	
	 set_params
  end

  def faq
	 set_params
  end

  def privacy_and_security
	 set_params
  end

  def contact_us
	 set_params false	
  end

  def donors_list
	 set_params false

	 @items_per_page = 10
	 if params['page'] == "-1"
		 @items_per_page = 10000000
	 end
	 sort = case params['sort']
           when "date"					: "created_at"
           when "name"					: "name"
           when "country"				: "country"
           when "sum"					: "sum_dollars"
           when "date_reverse"		: "created_at DESC"
           when "name_reverse"		: "name DESC"
           when "country_reverse"	: "country DESC"
           when "sum_reverse" 		: "sum_dollars DESC"

			  else    "created_at DESC"
           end

    @donors_pages, @donors = paginate :donors,
												  :conditions => [ "approved = ?", true],
												  :per_page => @items_per_page,
												  :order => sort
	 @donors.each do |d|
		 d.name = _('Anonymous') if d.is_anonymous
		 d.country = "" if d.country == "Unknown" || d.country == "."
		 d.message = " " if d.message.empty?
	 end

	 if request.xhr?
		 render :partial => "donors_list", :layout => false
	 end
  end

  def projects_and_expenses
	 set_params false
    @projects = Project.all_completed_projects(@lang, false, false)
  end

  def window_privacy_and_security
	 set_params false
	 render :layout => 'layouts/main_full',
		 :text => "<h3>#{@page_title}</h3>#{@page_content}"
  end

  def bank_details
    bank_details = Payment.bank_details(get_language())
	 render :layout => 'layouts/main_full', :text => bank_details.description
  end

  def tranzilla
    	set_params false
		if params[:language] && @lang != params[:language]
			params[:lang] = params[:language]
			get_language
		end
		
		@user = Common.get_user_by_lang(@lang)
		@first_pay = params[:first_pay] || ""
		@second_pay = params[:second_pay] || ""
		@currency = params[:currency] || "2"
		@sum = params[:sum] || ""
		@cred_type = params[:cred_type] || "1"
		@npay = params[:npay] || "2"
		@xxxFirstName = params[:xxxFirstName] || ""
		@xxxFirstName = CGI::unescape(@xxxFirstName)
		@xxxLastName = params[:xxxLastName] || ""
		@xxxLastName = CGI::unescape(@xxxLastName)
		@ccno = ""
		@expmonth = params[:expmonth] || "1"
		@expyear = params[:expyear] || "7"
		@mycvv = params[:mycvv] || ""
		@myid = params[:myid] || ""
		@anon = params[:anon] || "0"
		@xxxEmail = params[:xxxEmail] || ""
		@xxxEmail = CGI::unescape(@xxxEmail)
		@message = params[:message] || ""
		@message = CGI::unescape(@message)
		@response = params[:Response].to_i
		flash[:notice] = case @response
			when 0   : ""
			when 1   : @response.to_s
			when 3   : @response.to_s
			when 4   : @response.to_s
			when 6   : @response.to_s
			when 33  : @response.to_s
			when 35  : @response.to_s
			when 36  : @response.to_s
			when 37  : @response.to_s
			when 39  : @response.to_s
			when 57  : @response.to_s
			when 61  : @response.to_s
			when 107 : @response.to_s
			when 111 : @response.to_s
			when 138 : @response.to_s
			when 139 : @response.to_s
			else "Error"
		end

		render :layout => "tranzilla"
  end

  def webmoney
	set_params false
	render :layout => "webmoney"
  end	

  def thank_you # return from tranzilla after payment was made
       set_params false
	render :layout => "tranzilla"
  end

  def thank_you_paypal # return from PayPal after payment was made
       set_params false
		render :layout => "user"
  end

  private ######### PRIVATE FUNCTIONS #########################

  def set_params(to_render = true)
	 get_language
	 @action = action_name
	 if (@action == "window_privacy_and_security")
		 @action = "privacy_and_security"
	 elsif (@action == "index")
		 @action = "main"
	 elsif (@action == "thank_you_paypal")
		 @action = "thank_you"
    end

  	 @page_title = get_page_component(@lang, @action, "_page_title")
	 @page_content_short = get_page_component(@lang, @action, "_page_short")
	 @page_content = get_page_component(@lang, @action, "_page")

	 @payments = get_payments(@lang)
	 @host = request.env["HTTP_HOST"]
    render :action => "main" if to_render
  end

  def get_language
	lang_name = "English"
	@rtl = false
	if params[:lang]
		lang = params[:lang].downcase
		l_obj = Language.find(:first, :conditions => ["short_name = ?", lang])
		if !l_obj.nil?
			lang_name = l_obj.name
			@rtl = (l_obj.direction || "ltr") == "rtl"
		else
			l_obj = Language.find(:first, :conditions => ["name = ?", lang.capitalize])
			if !l_obj.nil?
				lang_name = l_obj.name
				@rtl = (l_obj.direction || "ltr") == "rtl"
			end
		end
	end
	Localization.lang = lang_name
	@privacy_and_security = url_for(:controller => "user", :action => "window_privacy_and_security")
	@tranzilla = url_for(:protocol => (RAILS_ENV == "production" ? "https://" : "http://"), :controller => "user", :action => "tranzilla")
	@bank_details = url_for(:controller => "user", :action => "bank_details")
	@webmoney = url_for(:controller => "user", :action => "webmoney")	
	@lang = lang_name
  end

  def get_page_component(lang, action, suffix)
    page_contents = PageContent.get_page_content_by_lang(lang)
    if page_contents.nil?
      ""
    else
      page_contents[action + suffix]
    end
  end

  def get_payments(lang)
	  Payment.all_payments_by_lang(lang)
  end

#   def paypal_ipn
#	set_params false
#  	@notify = Paypal::Notification.new(request.raw_post)
#       if @notify.acknowledge
#         order = Order.find(notify.item_id)
#         order.success = (notify.complete? and order.total == notify.amount) ? 'success' : 'failure'
#         order.save
#       end
#       render :nothing => true
#   end

end
