namespace :authengine do
  desc 'create an admin access account. Call rake "authengine:bootstrap[firstname,lastname,email_address]" (no spaces, quote the entire command)'
  task :bootstrap, [:firstName, :lastName, :email] => :environment do |t, args|
    if args.to_hash.keys.length < 3
      puts "Please specify firstname, lastname and email address"
    else
      attributes = {:firstName => args[:firstName],
                    :lastName  => args[:lastName],
                    :email => args[:email]}
      user = User.create(attributes)
      if user.valid?
        puts "Creating account for #{attributes[:firstName]} #{attributes[:lastName]} login: #{attributes[:login]}, password #{attributes[:password]}, email #{attributes[:email]}"
        locale = Rails.application.config.i18n.default_locale
        puts "Activation link is: #{Rails.application.routes.url_helpers.authengine_activate_path(locale, user.activation_code)}"
        if Role.exists?(:name => 'admin')
          role = Role.where(:name => 'admin').first
        else
          role.create(:name => 'admin')
          Controller.update_table
          ActionRole.bootstrap_access_for(role)
        end
        user.roles << role
      else
        puts "user could not be saved. #{user.errors.full_messages.join(', ')}"
      end
    end
  end
end
