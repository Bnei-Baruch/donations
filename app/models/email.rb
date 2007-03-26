class Email < ActiveRecord::Base
  apply_simple_captcha :message => _('Image text does not match - please re-enter.')

  validates_presence_of :name => _('Please enter name.')
  validates_presence_of :email => _('Please enter your email address.')
  validates_presence_of :comment => _('Please enter your comments.')

  def validate
      errors.add(_('Name'), _('is missing') ) if name == ""
      errors.add(_('Email Address'), _('is missing') ) if email == ""
      errors.add(_('Comments'), _('are missing') ) if comment == ""
  end

end
