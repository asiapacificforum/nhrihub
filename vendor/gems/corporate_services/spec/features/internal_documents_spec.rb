require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require 'active_support/number_helper'
require_relative '../helpers/corporate_services_context_internal_documents_spec_helpers'
#require_relative '../helpers/corporate_services_internal_documents_spec_helpers'
require_relative '../helpers/internal_documents_default_settings'
require 'internal_documents_behaviour'
require 'internal_documents_spec_common_helpers'

feature "internal document management", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  #include CorporateServicesInternalDocumentsSpecHelpers
  include InternalDocumentDefaultSettings
  include CorporateServicesContextInternalDocumentsSpecHelpers
  include InternalDocumentsSpecCommonHelpers
  it_behaves_like "internal documents"
end
