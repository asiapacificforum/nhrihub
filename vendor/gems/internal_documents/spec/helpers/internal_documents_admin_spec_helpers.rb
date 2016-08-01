require 'rspec/core/shared_context'

module InternalDocumentAdminSpecHelpers
  extend RSpec::Core::SharedContext
  def model
    InternalDocument
  end

  def admin_page
    internal_document_admin_path('en')
  end

  def filesize_context
    page.find('#internal_document_filesize')
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
            'controllers.controller_name' => ['internal_documents/filetypes','internal_documents/filesizes']).
      destroy_all
  end
end
