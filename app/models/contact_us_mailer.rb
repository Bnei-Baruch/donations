class ContactUsMailer < ActionMailer::Base

  def email(email)

    @subject = 'Donations - Contact Us Email'
    @body['sender_name'] = email.name
    @body['sender_email'] = email.email
    @body['comment'] = email.comment
    @recipients = Common.get_email_by_lang("English")
    @from       = [ "#{email.name} <#{email.email}>" ]
    @sent_on    = Time.now
    @headers    = {}

  end

end
