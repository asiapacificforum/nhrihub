# If the environment differs from the stage name
set :rails_env, 'production'
set :site_name, 'demo'

# .htaccess is required by passenger on this server
append :linked_files, 'public/.htaccess', 'config/initializers/action_mailer.rb', 'vendor/gems/authengine/app/views/authengine/user_mailer/signup_notification.en.html.erb'
append :assets_roles, 'demo' # triggers asset precompilation if necessary

set :migration_role, "demo" # triggers migration

set :passenger_roles, "demo" # triggers passenger restart after update

set :branch, "master"

# server-based syntax
# ======================
# Defines a single server with a list of roles and multiple properties.
# You can define all roles on a single server, or split them:

# server 'example.com', user: 'deploy', roles: %w{app db web}, my_property: :my_value
# server 'example.com', user: 'deploy', roles: %w{app web}, other_property: :other_value
# server 'db.example.com', user: 'deploy', roles: %w{db}



# role-based syntax
# ==================

# Defines a role with one or multiple servers. The primary server in each
# group is considered to be the first unless any  hosts have the primary
# property set. Specify the username and a domain or IP for the server.
# Don't use `:all`, it's a meta role.

# role :app, %w{deploy@example.com}, my_property: :my_value
# role :web, %w{user1@primary.com user2@additional.com}, other_property: :other_value
# role :db,  %w{deploy@example.com}



# Configuration
# =============
# You can set any configuration variable like in config/deploy.rb
# These variables are then only loaded and set in this stage.
# For available Capistrano configuration variables see the documentation page.
# http://capistranorb.com/documentation/getting-started/configuration/
# Feel free to add new variables to customise your setup.


#set :rvm_roles, :rvm
#role :rvm, "web"
role :app, "demo"

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '~/www/nhri-hub.com'

# otherwise bundler runs as:
# /bin/rvm default do bundle install --path ~/www/nhri-hub.com/shared/bundle --without development test --deployment --quiet as nhrihubc@nhrihub
# which it shouldn't when rvm is not available
#set :rvm_map_bins, []


# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult the Net::SSH documentation.
# http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start
#
# Global options
# --------------
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }

# The server-based syntax can be used to override options:
# ------------------------------------
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
server 'demo',
  user: 'nhrihubc',
  roles: %w{demo}#, db  would triggers whenever callback
# ssh_options configured in ~/.ssh/config
#ssh_options: {
#user: 'nhrihubc', # overrides user setting above
##keys: %w(/Users/lesnightingill/.ssh/nhri-hub.com.keys/id_rsa),
##keys: ["/Users/lesnightingill/.ssh/github_keys/id_rsa"],
#keys: ["/"],
##forward_agent: true,
#auth_methods: %w(publickey)
## password: 'please use keys'
#}

# could not get whenever gem's own update_crontab to work
# as the release path was not set, so use this workaround
namespace :deploy do
 task :update_crontab do
   on roles(:all) do
     within current_path do
       execute :bundle, :exec, :whenever, "--update-crontab", "~/www/nhri-hub.com/current/config/schedule.rb"
     end
   end
 end
end
after 'deploy:symlink:release', 'deploy:update_crontab'
