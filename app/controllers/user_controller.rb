class UserController < ApplicationController

  layout 'user', :except => [ :main_full, :show_projects, :show_donors ]

  #before_filter :set_params

  def main
	set_params
  end

  def index
	set_params
  end

  def main_full
	 lang = get_language     
	 @page_title = get_page_component(lang, params[:cur_action], "_page_title")
	 @page_content = get_page_component(lang, params[:cur_action], "_page")
	 render(:layout =>  'layouts/main_full')
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
    @donors = Donor.all_approved_donors(true)
  end

  def projects_and_expenses
	 set_params false
    @projects = Project.all_completed_projects("English", false, true)
	 @completed = false
  end

  def projects_history
	 set_params false
    @projects = Project.all_completed_projects("English", true, true)	
	 @completed = true
	 render :action => "projects_and_expenses"
  end

  def show_projects
    @projects = Project.all_completed_projects("English", params[:completed], false)
	 @completed = params[:completed]
	 render(:layout =>  'layouts/main_full')
  end

  def show_donors
    @donors = Donor.all_approved_donors(false)
	 render(:layout =>  'layouts/main_full')
  end

	def bank_details
		bank_details = Payment.bank_details(get_language())
		render :layout =>  'layouts/main_full', :text => bank_details.description
	end

require 'cgi'

	def tranzilla
    set_params false
		@first_pay = params[:first_pay] || ""
		@second_pay = params[:second_pay] || ""
		@currency = params[:currency] || "2"
		@sum = params[:sum] || ""
		@cred_type = params[:sum] || "1"
		@npay = params[:sum] || "2"
		@first_name = params[:first_name] || ""
		@last_name = params[:last_name] || ""
		@ccno = ""
		@expmonth = params[:expmonth] || "1"
		@expyear = params[:expyear] || "7"
		@mycvv = params[:mycvv] || ""
		@myid = params[:myid] || ""
		@anon = params[:anon] || "0"
		@email = params[:email] || ""
		@email = CGI::unescape(@email)
		@message = params[:message] || ""
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

  def thank_you # return from PayPal after payment was made
   set_params false
	render :layout => "tranzilla"
  end

  private

  def set_params(to_render = true)
	 lang = get_language
	 @action = action_name
	 if (@action == "index")
		 @action = "main"
	 end
        
   @page_title = get_page_component(lang, @action, "_page_title")
	 @page_content_short = get_page_component(lang, @action, "_page_short")
	 @page_content = get_page_component(lang, @action, "_page")

	 @payments = get_payments(lang)
	 
	 @host = request.env["HTTP_HOST"]
   render :action => "main" if to_render
  end

  def get_language
	 "English" # params[:lang]
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
