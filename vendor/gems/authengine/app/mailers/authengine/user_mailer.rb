class Authengine::UserMailer < ActionMailer::Base
  # subject for each email type is configured in config/locales/views/mailers/user_mailer/**.yml
  def signup_notification(user)
    @url = authengine_activate_url(:activation_code => user.activation_code, :locale => I18n.locale)
    send_mail(user)
  end

  def activate_notification(user)
    @url = login_url(:locale => I18n.locale)
    send_mail(user)
  end

  def forgotten_password_notification(user)
    @url  = "http://#{SITE_URL}/#{I18n.locale}/admin/new_password/#{user.password_reset_code}"
    send_mail(user)
  end

  def lost_token_notification(user)
    @url  = "http://#{SITE_URL}/#{I18n.locale}/admin/register_replacement_token_request/#{user.replacement_token_registration_code}"
    send_mail(user)
  end

protected
  def send_mail(user)
    @user = user
    mail( :to => "#{@user.email}",
          :subject => t('.subject', org_name: ORGANIZATION_NAME, app_name: APPLICATION_NAME),
          :date => Time.now,
          :from => "#{APPLICATION_NAME || "database"} Administrator<#{ADMIN_EMAIL}>"
        )
  end
end
