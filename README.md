== README

=== Description
NHRIDocs is an internal web application for National Human Rights Institutions ("NHRI") and other complaint handling institutions or human rights monitoring civil society organisations. It has a range of functionality designed to improve the efficiency and capacity of your organisation, including:
  -  A dynamic human rights indicators monitoring tool aligned to the UN framework of indicators with the ability to download all data and evaluate trends. (ref: http://www.ohchr.org/Documents/Publications/Human_rights_indicators_en.pdf, page 88)
  -  A complaints handling database (set up for complaints relating to human rights or good governance but also customisable)
  -  Strategic plan monitoring – link all of your organisations work to your strategic plan and be able to continuously monitor progress and have a downloadable report available at the click of a button
  -  ICC Accreditation module to help you collate all required documentation for accreditation and reaccreditation (ref: http://nhri.ohchr.org/EN/AboutUs/ICCAccreditation/Pages/default.aspx )
  -  Internal document file management system to store all of your organisation’s files and folders that can be accessible at any time via any computer with an internet connection
  -  Media monitoring tool to track information in the media and collect data that can be used to identify trends and emerging issues

All modules of the application have a range of functionality to assist in the course of your work such as the setting of automatic reminders, logging historical versions of all documents, assigning projects, complaints or other matters to registered users and setting different permission levels to protect the confidentiality and integrity of your documents. Each module can be enabled/disabled to reflect the work undertaken by your organisation.

=== Current Status
At this time NHRIdocs is a work in progress. This first release includes the functionality for managing users, organizations, and access privileges. The basic structure for internationalization is also present. None of the main functionality of the app is yet developed.

=== Ruby version
Configured in the .ruby-version file, to support the RVM version manager, look in that file for the currently-configured version

=== Internationalization
The basic structure for internationalization has been included, and the test suite tests the French translation of the navigation menu, the new user process, and the ActionMailer views pertaining to new user registration.
This provides an outline of the locale translation files that need to be added in the config/locales directory and subdirectories.
The url format for translated versions are (e.g.) your_domain/fr/admin/users.
The default locale is 'en', a different default may be configured within the config/application.rb file, as indicated by the notes within that file.
Page titles automatically default to the text in the i18n translation for the page .heading key, unless a translation for .title is provided.

=== Configuration
  email
  app-specific constants (orgname etc)
  timezone
  All dates and times are entered and displayed in the timezone configured for the application.

=== Database creation and initialization
  Configuring the first user

=== Access control
A role-based access control is included. The access is bootstrapped at installation time with a single administrator. This administrator may then define further roles (e.g. "staff", "intern")
Users with the role "admin" have access to the configuration of access permissions for each of the other roles.
When new users are added, they are assigned to the appropriate role in order to limit access to sensitive information.

=== Running the test suite
Integration testing uses Rspec. The tests are in spec/features. Headless testing uses the Poltergeist gem.
Run the entire integration test suite with:
    rspec spec/features

=== Deployment
Development updates are pushed manually to a git repository, using the normal git push procedure.
Deployment is automated using the Capistrano gem. The included capistrano deployment recipe is invoked by:
    cap deploy
This pulls from the git repo to a cached copy on the server, copies the update to a into the 'releases' directory, and symlinks the 'current' directory to point to the most recent release.
The 5 most recent releases are kept on the server.
Capistrano deployment also symlinks the config/database.yml and lib/constants files to copies in the 'shared' directory.
These files contain sensitive information and should be manually copied into the 'shared' directory. This is typically done just once when the app is first installed, as the information will typically remain unchanged for the life of the app.

=== Customizing the theme

=== Log rotation

=== Document storage

=== Modules
The application is structures as modules, located in the vendor/gems directory. The framework for a new module may be generated
with:
````RUBY
  rails generate nhridocs_module modname
```

This inserts the framework for a "modname" module as a Rails engine in the vendor/gems directory,
and functionality may be added here as required.
Modules should configure all the routes required for navigation within the module, in the module's own config/routes.rb file.
Included modules may be excluded simply by deleting them from the vendor/gems library and removing the links from
the top-level navigation menu.
The added module should be included in the main application's Gemfile, see the note regarding NHRIModules.
Database migrations pertaining to the module's resources should be added in the module's own db/migrate directory. They
will be included and run with the main applications migrations.


=== License
GPL V3, see LICENSE.txt
