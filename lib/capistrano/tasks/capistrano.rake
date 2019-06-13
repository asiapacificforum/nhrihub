namespace :server do

  desc "Upload database.yml file."
  task :upload_yml do
    on roles(:app) do
      execute "mkdir -p #{shared_path}/config"
      upload! StringIO.new(File.read("config/database.yml")), "#{shared_path}/config/database.yml"
    end
  end

  desc "Seed the database."
  task :populate do
    on roles(:app) do
      within "#{current_path}" do
        with rails_env: :production do
          execute :rake, "populate"
        end
      end
    end
  end

  desc "Symlinks config files for Nginx and Unicorn."
  task :symlink_config do
    on roles(:app) do
      execute "rm -f /etc/nginx/sites-enabled/default"

      execute "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{fetch(:application)}"
      execute "ln -nfs #{current_path}/config/unicorn_init.sh /etc/init.d/unicorn_#{fetch(:application)}"
   end
  end

end

namespace :deploy do
  desc "Load the initial schema - it will WIPE your database, use with care"
  task :db_schema_load do
    on roles(:db) do
      puts <<-EOF

      ************************** WARNING ***************************
      If you type [yes], rake db:schema:load will WIPE your database
      any other input will cancel the operation.
      **************************************************************

      EOF
      ask :answer, "Are you sure you want to WIPE your database?: "
      if fetch(:answer) == 'yes'
        within release_path do
          with rails_env: :production do
            rake 'db:schema:load'
          end
        end
      else
        puts "Cancelled."
      end
    end
  end
end
