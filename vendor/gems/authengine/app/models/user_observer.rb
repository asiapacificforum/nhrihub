class UserObserver < ActiveRecord::Observer
  def after_create(user)
    Authengine::UserMailer.signup_notification(user).deliver_now
  end

  def after_save(user)
    # the next line causes deprecation warnings in
    # actionmailer/lib/actionmailer/adv_attr_accessor.rb
    # this could become fatal when the deprecated methods are removed
    puts "user was saived, now do the mailing"
    puts "pending? #{user.pending?.to_s}"
    puts "recently forgot pw? #{user.recently_forgot_password?.to_s}"
    puts "recently reset pw? #{user.recently_reset_password?.to_s}"
    Authengine::UserMailer.activation(user).deliver_now if user.pending? # pending? true if user is activated
    Authengine::UserMailer.forgot_password(user).deliver_now if user.recently_forgot_password?
    Authengine::UserMailer.reset_password(user).deliver_now if user.recently_reset_password?
  end
end
