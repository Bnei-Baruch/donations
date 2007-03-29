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
    @donors = Donor.all_approved_donors(@lang, true)
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
		response = params[:Response].to_i
		flash[:notice] = case
			when response == 0 : ""
			when response == 1 : "Credit card is blocked"
			when response == 3 : "Contact your credit company"
			when response == 4 : "Credit card company refusal"
			when response == 6 : "ID number or CVV is incorrect"
			when response == 33 : "Defective card"
			when response == 35 : "Card is not permitted for transaction or type of credit"
			when response == 36 : "Credit card is expired"
			when response == 37 : "Rejected"
			when response == 39 : "Incorrect card number"
			when response == 57 : "ID number missing"
			when response == 61 : "Credit card number missing"
			when response == 107 : "Transaction amount is too high"
			when response == 111 : "Temporary cannot accept payments"
			when response == 138 : "You don't have permission to make payments"
			when response == 139 : "Number of installments is too high, maximum 12 installments are allowed"
			else "Error ##{response}"
		end

		render :layout => "tranzilla"
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
end
