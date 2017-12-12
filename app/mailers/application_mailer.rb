class ApplicationMailer < ActionMailer::Base
  default from: I18n.t('contact_email')
  layout 'email'
end
