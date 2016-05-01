# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )
assets = [ 'in_page_edit.js',
           'flash.js',
           'internal_documents.js',
           'projects.js',
           'projects.css',
           'performance_indicator.js',
           'fade.js',
           'slide.js']
Rails.application.config.assets.precompile += assets
