require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/siu_context_internal_documents_spec_helpers'
require_relative '../helpers/internal_documents_default_settings'
require 'internal_documents_behaviour'
require 'internal_documents_spec_common_helpers'

feature "internal doc behaviour", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  include InternalDocumentDefaultSettings
  include SiuContextInternalDocumentsSpecHelpers
  include InternalDocumentsSpecCommonHelpers
  it_behaves_like "internal documents"
end
