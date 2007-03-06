class UserController < ApplicationController

  layout 'user'

  #before_filter :set_params

  def index
	 set_params
  end

  def main
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

  private

  def set_params(to_render = true)
	 lang = "English" # params[:lang]
    @page_content = get_content("English")
	 @payments = get_payments("English")
	 @action = action_name
	 render :action => "main" if to_render
  end

  def get_content(lang)
    page_contents = PageContent.get_page_content_by_lang (lang)
    if page_contents.nil?
      "" 
    else
      page_contents[action_name + "_page"]
	 end
  end

  def get_payments(lang)
	  Payment.all_payments_by_lang(lang)
  end
end
