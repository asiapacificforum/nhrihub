# Configure these variables for your organization
# manually install this file, renamed as constants.rb into the capistrano shared directory
# make sure that the capistrano deployment script symlinks the file into lib/constants.rb
#
# if you are a developer, you can copy this file to lib/constants.rb
# but MAKE SURE it's ignored by git version control!
#
# parameters for the mailer
# look in vendor/gems/authengine/app/views/authengine/user_mailer/*
# to see how these parameters are used, you can define others in shared/constants.rb if you need them.
SITE_URL = "your_domain.org"
ADMIN_EMAIL = "support@#{SITE_URL}"
APPLICATION_NAME = "The database"
ORGANIZATION_NAME = "The organization"

