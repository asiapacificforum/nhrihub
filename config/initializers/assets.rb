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
           'single_month_datepicker.js',
           'attached_documents.js',
           'single_note_modal.js',
           'projects.js',
           'projects.css',
           'complaints.js',
           'communication.js',
           'complaints.css',
           'bootstrap-select.css',
           'scrolling_dropdown.css',
           'performance_indicator.js',
           'ractive_validator.js',
           'fade.js',
           'slide.js',
           'ractive_local_methods.js',
           'string.js',
           'file_upload.js',
           'file_input_decorator.js',
           'remindable.js',
           'notable.js',
           'media_issues.css',
           'message_block.css',
           'u2f-api.js',
           'mock_yubikey.js',
           'jsrsasign/jsrsasign-4.7.0-all-min.js',
           'confirm_delete_modal.js']
Rails.application.config.assets.precompile += assets
