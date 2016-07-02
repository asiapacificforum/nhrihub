require 'rspec/core/shared_context'

module CorporateServicesAdminSpecHelpers
  extend RSpec::Core::SharedContext
  def admin_page
    corporate_services_admin_path('en')
  end

  def filesize_context
    page.find('#internal_document_filesize')
  end

  def model
    InternalDocument
  end

  def filetypes_context
    page.find(filetypes_selector)
  end

  def filetypes_selector
    '#internal_document_filetypes'
  end

  def remove_add_delete_fileconfig_permissions
    ActionRole.
      joins(:action => :controller).
      where('actions.action_name' => ['create', 'destroy', 'update'],
            'controllers.controller_name' => ['corporate_services/internal_documents/filetypes','corporate_services/internal_documents/filesizes']).
      destroy_all
  end
end
