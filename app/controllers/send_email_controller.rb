class SendEmailController < ApplicationController

  layout 'email'

  def email_get_data
    @email = Email.new
  end

  def send_email
    @email = Email.new(params[:email])
    if @email.save_with_captcha
	email = ContactUsMailer.create_email("English", @email)
	#render(:text => "<pre>" + email.encoded + "</pre>" )
	ContactUsMailer.deliver(email)
	render(:text => _('Your email was successfully sent.') )
    else
      render :action => 'email_get_data'
    end
  end

end
