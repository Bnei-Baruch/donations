# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_don_session_id'
  filter_parameter_logging "ccno", "mycvv", "myid"
  RAILS_DEFAULT_LOGGER.level = Logger::ERROR

  def can_manage_pages?
	  #@is_root
	  session[:user_id] && User.find_by_id(session[:user_id]).name == "boka"
false
  end

  private
  
  def authorize
    unless User.find_by_id(session[:user_id])
      flash[:notice] = "Please log in"
      redirect_to(:controller => "login" , :action => "login" )
    end
  end

end
