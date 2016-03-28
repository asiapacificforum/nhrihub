assets = [ 'nhri/reference_documents.js',
           'nhri/terms_of_reference.js',
           'nhri/minutes.js',
           'issues.js',
           'nhri/headings.js',
           'nhri/headings.css',
           'jquery_datepicker.js',
           'nhri/indicators.js',
           'nhri/monitors.js']

Rails.application.config.assets.precompile += assets
