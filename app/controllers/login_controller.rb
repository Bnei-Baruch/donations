class LoginController < ApplicationController

  layout "admin"

  before_filter :authorize, :except => :login

  def add_user
    if is_supervisor
	redirect_to(:action => "list_users" )
    else
      @user = User.new(params[:user])
      if request.post? and @user.save
        flash.now[:notice] = "User #{@user.name} created"
        @user = User.new
      end 
    end
  end

  def login
    session[:user_id] = nil
    if request.post?
      user = User.authenticate(params[:name], params[:password])
      if user
        session[:user_id] = user.id
        redirect_to(:action => "index" )
      else
        flash[:notice] = "Invalid user/password combination"
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to(:action => "login" )
  end

  def index
  end

  def delete_user
    redirect = true	
    if request.post?
	user = User.find(params[:id])
	begin
	  if (user.name != "supervisor")
	    user.destroy
	    flash[:notice] = "User #{user.name} deleted"
	  else
	    redirect = false	
	  end
	rescue Exception => e
 	  flash[:notice] = e.message	
	end
    end
    if redirect
	redirect_to(:action => :list_users)
    end
  end

  def list_users
    @all_users = User.find(:all)
  end

  def after_destroy
    if User.count.zero?
	raise "Can't delete last user"
    end
  end

  def is_supervisor
    user = User.find(session[:user_id])
    user.name == "supervisor"
  end
	
end
