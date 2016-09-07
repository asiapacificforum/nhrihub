class ApplicationMailer < ActionMailer::Base
  default from: "#{APPLICATION_NAME || "database"} Administrator<#{ADMIN_EMAIL}>"
  layout 'mailer'
end

