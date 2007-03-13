class UserController < ApplicationController

  layout 'user'

  #before_filter :set_params

  def main
		set_params
  end

  alias_method :index, :main

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
    @donors = Donor.all_approved_donors()
  end

  def projects_and_expenses
    @projects = Project.all_completed_projects("English", false)
	 set_params false
  end

  def projects_history
    @projects = Project.all_completed_projects("English", true)	
	 set_params false
  end

  def show_project
	  @project = Project.find(:first, :conditions => ["id = ?", params[:id]])
  end

	def cancel_return # return from PayPal after "Cancel" was clicked
	 set_params false
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
    @page_content = get_content(lang, @action)
	 @payments = get_payments(lang)
	 render :action => "main" if to_render
  end

  def get_language
	 "English" # params[:lang]
  end

  def get_content(lang, action)
    page_contents = PageContent.get_page_content_by_lang (lang)
    if page_contents.nil?
      "" 
    else
      page_contents[action + "_page"]
	 end
  end

  def get_payments(lang)
	  Payment.all_payments_by_lang(lang)
  end
end
