class SendEmailController < ApplicationController

  def email_get_data
    @email = Email.new
  end

  def send_email
    @email = Email.new(params[:email])
    if @email.save
	email = ContactUsMailer.create_email(@email)
	#render(:text => "<pre>" + email.encoded + "</pre>" )
	ContactUsMailer.deliver(email)
	render(:text => "Your email was successfully sent." )
	#flash[:notice] = "Your email was successfully sent."
    else
      render :action => 'email_get_data'
    end
  end

end
