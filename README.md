[![Code Climate](https://codeclimate.com/github/asiapacificforum/nhridocs/badges/gpa.svg)](https://codeclimate.com/github/asiapacificforum/nhridocs)
# NHRI Hub
## Description
NHRI Hub is an internal web application for National Human Rights Institutions ("NHRI") and other complaint handling institutions or human rights monitoring civil society organisations. It comprises a suite of modules that assist in the planning and management of the NHRI's internal processes, accreditation, and performance metrics. It has a range of functionality designed to improve the efficiency and capacity of your organisation, including:
  -  A dynamic human rights indicators monitoring tool aligned to the UN framework of indicators with the ability to download all data and evaluate trends. (ref: [http://www.ohchr.org/Documents/Publications/Human_rights_indicators_en.pdf](http://www.ohchr.org/Documents/Publications/Human_rights_indicators_en.pdf), page 88)
  -  A complaints handling database (set up for complaints relating to human rights or good governance but also customisable)
  -  Strategic plan monitoring – link all of your organisations work to your strategic plan and be able to continuously monitor progress and have a downloadable report available at the click of a button
  -  GANHRI Accreditation module to help you collate all required documentation for accreditation and reaccreditation (ref: [http://nhri.ohchr.org/EN/AboutUs/ICCAccreditation/Pages/default.aspx](http://nhri.ohchr.org/EN/AboutUs/ICCAccreditation/Pages/default.aspx) )
  -  Internal document file management system to store all of your organisation’s files and folders that can be accessible at any time via any computer with an internet connection
  -  Media monitoring tool to track information in the media and collect data that can be used to identify trends and emerging issues

All modules of the application have a range of functionality to assist in the course of your work such as the setting of automatic reminders, logging historical versions of all documents, assigning projects, complaints or other matters to registered users and setting different permission levels to protect the confidentiality and integrity of your documents. Each module can be enabled/disabled to reflect the work undertaken by your organisation.

## Current Status
As of June 12, 2017 NHRIdocs is a "feature complete", and is being prepared for its first beta test in a live environment.

## Ruby version
Configured in the .ruby-version file, to support the RVM version manager, look in that file for the currently-configured version

## Internationalization
The basic structure for internationalization has been included.

For languages other than English, locale translation files need to be added in the config/locales directory and subdirectories, as well as the config/locales directories and subdirectories of all the modules in vendor/gems. Translations may also be required for javascript, these may be found in lib/assets/javascripts/xx.js

Each module also includes translation files in its config/locales directory, and for javascript in lib/assets/javascripts/locales

The url format for translated versions are (e.g. French version) your_domain/fr/admin/users.

The default locale is 'en', a different default may be configured within the config/application.rb file, as indicated by the notes within that file.
Page titles automatically default to the text in the i18n translation for the page .heading key, unless a translation for .title is provided.

The text of emails is contained in the localized files in the vendor/gems/authengine/app/views/authengine/user_mailer directory. Each of the files is localized to English with the .en extension, if another locale is to be supported, the appropriately-localized email files must be added to this directory.

## Security
### Two-factor Authentication
Two-factor authentication is supported, using the [emerging FIDO standard](https://fidoalliance.org/). The second authentication factor is provided by the [Yubico FIDO U2F Security Key](https://www.yubico.com/products/yubikey-hardware/fido-u2f-security-key).

At the this time (September 2016), only the Chrome browser supports this protocol, therefore this is the requirement for this application when two-factor authentication is enabled. Furthermore, the https transport layer protocol is required, necessitating a public-key certificate on the server, issued by a Chrome-recognized certification authority. Future support in other browsers has been announced.

For convenience, the [letsencrypt_plugin](https://github.com/lgromanowski/letsencrypt-plugin) is bundled with the application, facilitating a command-line certificate request to the [Let's Encrypt](https://letsencrypt.org/) certification authority API. However there is no requirement to use Let's Encrypt certificates.

In some scenarios it is desirable to temporarily, or even permanently, disable the two-factor authentication feature. This is achieved by configuration of an environment variable from the config/env.yml file. This file is symlinked to the file of the same name in the shared/config directory in the capistrano file structure. If the file does not exist, two-factor authentication defaults to "enabled".

### Content Security Policy
Content Security Policy (CSP) headers are generated by the [twitter/secureheaders gem](https://github.com/twitter/secureheaders). Application configuration for this gem is in the config/initializers/secure_headers.rb file.

## Configuration
### TimeZone
Internally, dates are stored in UTC. The timezone for interpreting all user input dates is configured by the TIME_ZONE parameter in the lib/constants file, which is symlinked on the server to the Capistrano shared directory.

The permitted values for the application's TIME_ZONE parameter are those values defined in Rails' [ActiveSupport::TimeZone](http://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html)

### Email
The configuration file for configuring access to the server's smtp daemon is config/initializers/action_mailer.rb. Due to the sensitive information, and because it is required to persist through software updates, the file is symlinked to a copy in the Capistrano shared directory. A file called config/initializers/action_mailer_example.rb is included as a guide on how to configure the real configuration file. Consult [Rails Guides: Action Mailer Basics](http://guides.rubyonrails.org/action_mailer_basics.html) for further information on mailer configuration.

### Application Constants
The collection of attributes that may differ between installation instances of the application are stored in lib/constants.rb. Be sure to read and configure this file with the appropriate values.

## Database creation and initialization
When it is first installed, the access privileges must be "bootstrapped" to permit the first user access. After this, the first user may configure further users through the web user interface.

The first user is configured via a rake command-line utility on the server by running:

```
rake "authengine:bootstrap[firstName,lastName,email]"
```
where firstName, lastName, and email are replaced by the parameters appropriate for the first user. A registration email is sent to the user at the configured email address. If two-factor authentication is enabled, the user will be required to have an access token in order to be able to complete the registration procedure.

## Access control
A role-based access control is included. The access is bootstrapped at installation time with a single administrator. This administrator may then define further roles (e.g. "staff", "intern").

For convenience a "developer" role is automatically created, granted full access privileges, and not revealed in the role managment or access management pages.

Users with the role "admin" have access to the configuration of access permissions for each of the other roles.

When new users are added, they are assigned to the appropriate role in order to limit access to sensitive information.

## Log files
### Log rotation
The log rotation is assumed to be handled by the unix logrotate facility, specified in /etc/logrotate.d/rails. A typical configuration might be:
```
/var/www/nhri_docs/shared/log/production.log {
  daily
  rotate 14
  notifempty
  missingok
  compress
  sharedscripts
  copytruncate
  endscript
}
```
### Tagged log messages
The production log file entries are tagged with the ip address of the request and the user_id of the currently logged-in user (if there is a currently logged-in user). So a typical log entry might be:
```
I, [2016-09-12T03:19:36.432118 #22021]  INFO -- : [72.35.204.5] [731]   Rendering vendor/gems/projects/app/views/projects/index.haml within layouts/application
```
where 72.35.204.5 is the ip address and 731 is the user_id.

## Running the test suite
Integration testing uses Rspec with poltergeist/phantomjs as the headless client. The tests are in spec/features.

Run the main application integration test suite with:
```
rspec spec/features
```

Each of the modules includes its own integration tests. The rails_helper from the main app is included in the module spec/features tests, so the same testing environment applies.

Note that phantomjs 2.0.0 has issues with file uploading (see https://github.com/teampoltergeist/poltergeist/issues/594). So use phantomjs 1.9.2 for headless testing.

## Testing with Internet Explorer
Running integration tests with Internet Explorer is a little more complex. A windows computer is required, running IE >= 10.
This computer also needs to have Java, selenium-server-standalone, and IEDriver loaded. If it has a firewall, permissions must be configured sufficient to support this test configuration.
On the windows computer, start selenium-server with:
```
java -jar /path/to/selenium-server-standalone-xxx.jar -Dwebdriver.ie.driver=/path/to/IEDriverServer.exe -browser "browserName=internet explorer, version=11"
```

On the computer (typically a Mac) that is running the tests and the application, the spec_helper file includes Capybara configuration for remote IE testing. Uncomment the configuration as indicated in the file.
The computer on which Internet Explorer is running should also have pdf files for testing file upload. The following pdf files are required:
first_upload_file.pdf (size less than the configured size limit)
big_upload_file.pdf (size greater than configured size limit)
first_upload_image_file.png (for testing of unpermitted file upload check)

The computer 'driving' the test and hosting the application must have a running instance of the application, in the test environment. The Capybara config specifies port 3010. Initiate the app with rails server -e test -p 3010.

Two parameters related to the windows computer must be configured for Capybara: in the file lib/capybara_remote.rb, configure local values for the local network address of the windows computer, and the path to the test upload files (see above for which files are required to be present).

A couple of windows configurations must be set in order to support this test scenario:
1. Registry key configuration, see https://code.google.com/p/selenium/wiki/InternetExplorerDriver
2. If the tests, in particular the character entry in text fields, is running very slowsly, you may need to use the 32-bit version of IEDriverServer. See https://www.microsoft.com/en-us/download/details.aspx?id=44069
3. Zone permissions under the windows "Internet options" configuration menu may need to be configured to be the same for all zones.

### Javascript testing
In some cases test coverage of the javascript is achieved with integration testing by means of rspec features.

In other cases, dedicated javscript tests have been used. These use a suite of javascript test libraries, including:

* [Teaspoon](https://github.com/modeset/teaspoon)
* [MagicLamp](https://github.com/crismali/magic_lamp)
* [Mocha](https://mochajs.org/)
* [Chai](http://chaijs.com/)

#### Browser testing (slower, but facilitates debugging)
To run the javascript test suite, first start a rails server up in the special environment configured for javascript testing:
```
rails s -e jstest -p 5000 -P `pwd`/tmp/pids/jstestserver.pid
```
This environment is configured for no asset caching, as in development environment. It has its own database, so that objects can be created and destroyed without affecting the development database, and also its own log (log/jstest.log).
Then point the browser to the teaspoon rack endpoint on that server:
```
localhost:5000/teaspoon/testname
```
where testname is the name of the test suite you wish to run. The following js test suites are included:
* media
* internal_documents
* projects
* headings
* complaints
* strategic_plan
* default (runs all other suites)

#### Headless testing (faster, but debugging is more difficult, use this for regression testing)
Requires phantomjs version 2.1.1 or later. From the application directory command line run
    RAILS_ENV=jstest teaspoon --suite media
or
    RAILS_ENV=jstest rake teaspoon suite=default

## Deployment
Development updates are pushed manually to a git repository, using the normal git push procedure.

Deployment is automated using the Capistrano gem using:
```
    cap production deploy
```
This pulls from the git repo to a cached copy on the server, copies the update to a into the 'releases' directory, and symlinks the 'current' directory to point to the most recent release. As configured in config/deploy.rb, capistrano pulls from the main repo of the application, if you have forked the app, you will need to point capistrano to your own fork.

The 5 most recent releases are kept on the server.

Capistrano deployment also symlinks the config/database.yml and lib/constants files to copies in the 'shared' directory.
These files contain sensitive information and should be manually copied into the 'shared' directory. This is typically done just once when the app is first installed, as the information will typically remain unchanged for the life of the app.

The following files are required by the app, and are not included in the source due to their sensitive content. They must be manually copied into the shared directory:
* config/database.yml
* config/secrets.yml
* lib/constants.rb
* deploy/production.rb
* app/assets/images/banner_logo.png
* config/locales/site_specific/en.yml
* config/locales/site_specific/fr.yml
* key/keyfile.pem
* shared/config/letsencrypt_plugin.yml
* shared/config/env.yml

## Configuring SSL
[Letsencrypt](http://letsencrypt.org) may be used to obtain an ssl certificate. This is facilitated by the [letsencrypt_plugin gem](https://github.com/lgromanowski/letsencrypt-plugin). This gem needs a configuration file, and it's stored in the shared/config/letsencrypt_plugin.yml where capistrano symlinks files. Refer to the gem's README for information on the parameters that must be included. The RSA private key is also symlinked by capistrano to shared/key/keyfile.pem.

After following the instructions on the letsencrypt_plugin gem, you will have ssl certificates for your site stored in the certificates directory.

For reference, within this application, you must first be logged-in as the user with read/write privileges, and then from the command line, issue the command:

```
RAILS_ENV=production bundle exec rake letsencrypt_plugin
```

Alternatively you may exclude this gem from Gemfile (and remove it from config/routes.rb) and obtain the site ssl certificate by another means.

## Customizing the theme
The colour scheme used for rendering the site are all collected in app/assets/stylesheets/theme.scss.

## Document storage
Uploaded documents are stored within the filesystem, under the Capistrano shared directory, in uploads/store, with filenames assigned by the application.

## Storing Multiple Site Variants in a Single Repo
The set of files that localise the application for a particular client are contained in config/site_specific_linked_files/%site_name/*.

The files contain either sensitive information pertaining to a particular site (e.g. database password) or simply site-specific attributes (banner text, theme colours, email text). The files may be incorporated locally (during development) and dispatched to the appropriate server with the following workflow:

### Add a new client to the repo

1. invoke:
```
rails g nhri_hub_site site_name
```
This does the following:
* sets up the directory structure and some place holders and example files for the site-specific files
* adds the root directory of the site configuration to .gitignore, so that any site-specific files are not added to the repository.
* adds a capistrano deploy file to the config/deploy directory for configuration of this site's capistrano configuration

2. Within the newly-created config/site_specific_linked_files/site_name create the localization files required for the site, use the set of files in config/site_specific_linked_files/demo/* as a guide.

3. Configure the capistrano deploy file created in step 1 with the linked files that capistrano should add to the shared directory on the server. This list of linked files should match exactly the files within the config/site_specific_linked_files/%site_name% directory.

### Deploy the site
The localization files will be stored on the server in the Capistrano shared directory. Invoke capistrano for the site with 
```
cap %site_name% deploy
```
The site-specific files will be automatically uploaded from the config/site_specific_linked_files/%site_name% directory.

### Configure Local Machine with Site-Specific Configuration
A rake task is provide to link the site-specific configuration for a site to the local repository files, so that the app takes on the site's characteristics when the local rails server is started. Use:
```
rake "localize[au]"
```
and then restart the Rails server to see on the development machine how the site looks that is represented in config/site_specific_linked_files/au/*.

## Modules
The application is structures as modules, located in the vendor/gems directory. The framework for a new module may be generated
with:
    rails generate nhridocs_module modname

This inserts the framework for a "modname" module as a Rails engine in the vendor/gems directory, and functionality may be added here as required.
Modules should configure all the routes required for navigation within the module, in the module's own config/routes.rb file.
A newly-generated module is connected into the application by
1. Add it to the Gemfile and install with the 'bundle' command
2. Add links to the top-level navigation menu (config/navigation.rb)
Included modules may be excluded simply by deleting them from the vendor/gems library and removing the links from
the top-level navigation menu and removing it from the Gemfile.
Database migrations pertaining to the module's resources should be added in the module's own db/migrate directory. They
will be included and run with the main application's migrations.

## Shared Models
The root application includes models, controllers and views that appear in multiple modules, and may be included in new modules. They are:
1. Reminders
2. Notes
Each of these shared elements has a feature test spec implemented as an rspec shared behaviour. So the behaviour can be tested when the shared model is incorporated as an association into a module.

### Sending Reminders
A rake task is provided that should be run each day, exactly once per day, to send any reminders that are due on that day. This is done by the server's cron daemon. The configuration of the cron daemon is accomplished with the NHRI Hub app using the [whenever gem](https://github.com/javan/whenever). The configuration file is config/schedule.rb.

# Github Pages
All the files for a static informational website, served a Jekyll server, are included in the /docs directory. The Jekyll gem is included in the development environment, and is also available on GitHub to serve files from this directory. It is viewable on the web at [http://asiapacificforum.github.io/nhrihub/](http://asiapacificforum.github.io/nhrihub/). To view this locally, invoke
```
jekyll serve
```
from the /docs directory and point your browser to localhost::4000.

## License
GPL V3, see LICENSE.txt
