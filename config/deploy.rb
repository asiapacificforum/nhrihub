# config valid only for current version of Capistrano
lock '3.6.0'

set :application, 'nhri_docs'
set :repo_url, 'git@github.com:asiapacificforum/nhridocs.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
set :linked_files, fetch(:linked_files, []).push('config/database.yml',
                                                 'config/secrets.yml',
                                                 'lib/constants.rb',
                                                 'config/deploy/production.rb',
                                                 'app/assets/images/banner_logo.png',
                                                 'config/locales/site_specific/en.yml',
                                                 'config/locales/site_specific/fr.yml',
                                                 'key/keyfile.pem',
                                                 'config/letsencrypt_plugin.yml',
                                                 'config/env.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
set :linked_dirs, fetch(:linked_dirs, []).push('certificates',
                                               'log',
                                               'tmp/pids',
                                               'tmp/cache',
                                               'tmp/sockets',
                                               'vendor/bundle',
                                               'lib/import_data')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

#set :passenger_restart_with_sudo, true
#set :passenger_restart_command, 'passenger-config restart-app'
#set :passenger_restart_options, -> { "#{deploy_to} --ignore-app-not-running" }

# for hte capistrano-faster-assets gem
#set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb) + Dir.glob('vendor/gems/**/app/assets')
set :assets_dependencies, %w(app/assets lib/assets vendor/assets Gemfile.lock config/routes.rb) + Dir.glob('vendor/gems/**/app/assets')


namespace :deploy do

  after :updated, 'whenever:update_crontab'
  after :reverted, 'whenever:update_crontab'

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      #Here we can do anything such as:
      #within release_path do
        #execute :rake, 'tmp:cache:clear'
      #end
    end
  end

  #Beware... this will overwrite critical files
  #before :finishing, 'linked_files:upload_files' # beware this clobbers database.yml

end
