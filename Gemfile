source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.0'
# Use postgresql as the database for Active Record
gem 'pg'
#gem 'mysql'
#gem 'mysql2'
# Use SCSS for stylesheets
gem 'sass-rails'#, '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'#, '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
#gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
##gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
##gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# to control crontab from ruby
gem 'whenever', :require => false

group :development do
  # Use Capistrano for deployment
  gem 'capistrano-rails'
  # capistrano add-ons
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano-passenger', '= 0.0.2'
  gem 'capistrano-faster-assets', :git => "git@github.com:lazylester/capistrano-faster-assets.git"
  #gem 'capistrano-faster-assets'
  # specify higher rev than required by capistrano in order to get
  # fixed connection pooling and faster deploys
  gem 'sshkit', '~> 1.5'
end

# Use debugger

#gem 'haml'
gem 'haml-rails'

group :development, :test, :jstest do
  gem 'rspec-rails'
  #gem 'capybara', :git => "git@github.com:lazylester/capybara.git", :branch => "attach_file_remote"
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
  #gem 'debugger'

  gem 'teaspoon'
  gem 'teaspoon-mocha'
  gem 'magic_lamp'
  gem 'launchy'
  gem 'byebug'
end
gem 'js-routes'
gem 'bootstrap-sass'
gem 'simple-navigation-bootstrap'
gem 'font-awesome-sass'
#gem 'simple-navigation', '~> 4.0.3' seems to have some problems with simple-navigation-bootstrap
gem 'simple-navigation', '~> 3.14.0'
gem 'simplecov', :require => false, :group => [:test, :jstest]
gem 'poltergeist', group: [:test, :jstest]
gem 'factory_girl_rails', '~> 4.0'
gem 'faker'

gem 'letsencrypt_plugin', :github => "lgromanowski/letsencrypt-plugin", :ref => "6ef3a2ea450af2cec4be906842ebcbf809b5fc46"

###not needed in rails 5
###gem 'quiet_assets', group: :development
gem "refile", :git => "git@github.com:refile/refile.git", :ref => "d7a42", require: "refile/rails" # for rails5 compatibility
gem "sinatra", github: "sinatra/sinatra", :ref => "285275b42fa1bf096a5c9559b6cead2f31b65b66" # for rack 2 compatibility as required for rails5
gem "rack", github: "rack/rack" # also for sinatra 2.0.0-alpha support
gem "rack-protection", github: "sinatra/rack-protection"
gem "rails-settings-cached", '~> 0.4.2'
gem "underscore-rails"
gem "capistrano-linked-files"
gem "message_block", github: "lazylester/message_block"

### NHRI Modules:
gem 'authengine', :path => 'vendor/gems/authengine'
gem 'corporate_services', :path => 'vendor/gems/corporate_services'
gem 'outreach_media', :path => 'vendor/gems/outreach_media'
gem 'nhri', :path => 'vendor/gems/nhri'
gem 'siu', :path => 'vendor/gems/siu'
gem 'complaints', :path => 'vendor/gems/complaints'
gem 'projects', :path => 'vendor/gems/projects'
gem 'internal_documents', :path => 'vendor/gems/internal_documents'
