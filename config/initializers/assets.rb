# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
assets = [ 'in_page_edit.js',
           'flash.js',
           'internal_documents.js',
           'internal_documents.css',
           'jquery_datepicker.css',
           'projects.js',
           'projects.css',
           'complaints.js',
           'complaints.css',
           'performance_indicator.js',
           'fade.js',
           'slide.js',
           'ractive_local_methods.js',
           'string.js',
           'file_upload.js']
Rails.application.config.assets.precompile += assets
