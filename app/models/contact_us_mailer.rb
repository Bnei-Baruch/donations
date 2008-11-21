class ContactUsMailer < ActionMailer::Base

  def email(lang, email)

    @subject = 'Donations - Contact Us Email'
    @body['sender_name'] = email.name
    @body['sender_email'] = email.email
    @body['comment'] = email.comment
    @recipients = Common.get_email_by_lang(lang)
    @from       = [ "#{email.name} <#{email.email}>" ]
    @sent_on    = Time.now
    @headers    = {}

  end

  def acknowledge(lang, recipient_email, recipient_name, sum, currency)

	@subject = 'Confirmation'
	@body['recipient_name'] = recipient_name
	@body['sum'] = sum
	@body['currency'] = currency
	@body['lang'] = lang
    @recipients = recipient_email
    @from       = [ "Bnei Baruch Association <michak@kbb1.com>" ]
    @sent_on    = Time.now
    @headers    = {}

  end

end
