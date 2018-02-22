class ApplicationMailer < ActionMailer::Base
  default from: Rdr.default_from_address
  layout 'mailer'
end
