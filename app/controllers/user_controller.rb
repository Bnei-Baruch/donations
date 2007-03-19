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
    @projects = Project.all_completed_projects("English", false, true)
	 set_params false
  end

  def projects_history
    @projects = Project.all_completed_projects("English", true, true)	
	 set_params false
  end

  def show_projects
    @projects = Project.all_completed_projects("English", params[:completed], false)
  end

  def show_donors
    @donors = Donor.all_approved_donors(true)
  end

	def bank_details
		bank_details = Payment.bank_details(get_language())
		render :text => bank_details.description
	end

	def tranzilla
    set_params false
		@first_pay = params[:first_pay] || ""
		@second_pay = params[:second_pay] || ""
		@currency = params[:currency] || "2"
		@summ = params[:summ] || ""
		@cred_type = params[:summ] || "1"
		@npay = params[:summ] || "2"
		@first_name = params[:first_name] || ""
		@last_name = params[:last_name] || ""
		@ccno = ""
		@expmonth = params[:expmonth] || "1"
		@expyear = params[:expyear] || "7"
		@mycvv = params[:mycvv] || ""
		@myid = params[:myid] || ""
		@anon = params[:anon] || "0"
		@email = params[:email] || ""
		@message = params[:message] || ""
		response = params[:Response].to_i
		@error = case
			when response == 0 : ""
			when response == 1 : "Blocked Credit Card"
			when response == 3 : "You have to obtain a permission from the Card Issuer"
			when response == 4 : "Credit Card Issuer's refusal"
			when response == 6 : "Wrong ID number"
			when response == 33 : "Wrong Card"
			when response == 35 : "Wrong kind of credit"
			when response == 36 : "The card is expired"
			when response == 39 : "Wrong card number"
			when response == 57 : "Missed ID"
			when response == 61 : "Missed credit card number"
			when response == 107 : "Too large sum"
			when response == 111 : "Temporary cannot accept installments"
			when response == 138 : "No permission for installments"
			when response == 139 : "To many installments"
			else "Error # #{response}"
		end

		render :layout => "tranzilla"
  end

  def thank_you # return from PayPal after payment was made
   set_params false
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
    page_contents = PageContent.get_page_content_by_lang (lang)
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
