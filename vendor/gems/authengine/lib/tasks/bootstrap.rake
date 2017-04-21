namespace :authengine do
  desc "send_email"
  task :send_email => :environment do
    Authengine::UserMailer.send(:signup_notification, User.first).deliver_now
  end
  desc "reset users"
  task :reset_users => :environment do
    User.all.first.destroy unless User.all.empty?
  end
  desc 'create an admin access account. Call rake "authengine:bootstrap[firstname,lastname,email_address]" (no spaces, quote the entire command)'
  task :bootstrap, [:firstName, :lastName, :email] => :environment do |t, args|
    if args.to_hash.keys.length != 3
      puts "command is: rake \"authengine:bootstrap[firstname,lastname,email_address]\" (no spaces, quotes as shown)"
    else
      attributes = {:firstName => args[:firstName],
                    :lastName  => args[:lastName],
                    :email => args[:email]}
      user = User.create(attributes)
      puts "Creating account for #{attributes[:firstName]} #{attributes[:lastName]}, email #{attributes[:email]}"
      locale = Rails.application.config.i18n.default_locale
      puts "Activation link is: #{Rails.application.routes.url_helpers.authengine_activate_path(locale, user.activation_code)}"
      role = Role.find_or_create_by(:name => 'admin')
      Controller.update_table
      ActionRole.bootstrap_access_for(role)
      user.roles << role
    end
  end
end
