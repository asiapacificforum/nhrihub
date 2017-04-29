ActionMailer::Base.smtp_settings = {
  :address => "nhri-hub.com",
  :port => 25,
  :domain => "nhri-hub.com",
  :authentication => :login,
  :user_name => "admin@nhri-hub.com",
  :password => "(DiOHzySqPV)", # 4/28/17
  :openssl_verify_mode => OpenSSL::SSL::VERIFY_NONE
#  :enable_starttls_auto => false
  }


Rails.application.config.action_mailer.raise_delivery_errors = true
Rails.application.config.action_mailer.delivery_method = :smtp
