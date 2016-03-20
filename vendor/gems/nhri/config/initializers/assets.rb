assets = [ 'nhri/reference_documents.js',
           'nhri/terms_of_reference.js',
           'nhri/minutes.js',
           'issues.js',
           'headings.js',
           'nhri/headings.css',
           'jquery_datepicker.js',
           'nhri/indicators.js']

Rails.application.config.assets.precompile += assets
