require 'rspec/core/shared_context'
require 'admin_spec_common_helpers'

module CorporateServicesAdminSpecHelpers
  extend RSpec::Core::SharedContext
  include AdminSpecCommonHelpers

  def remove_add_delete_fileconfig_permissions
    ActionRole.
      joins(:action => :controller).
      where('actions.action_name' => ['create', 'destroy', 'update'],
            'controllers.controller_name' => ['corporate_services/internal_documents/filetypes','corporate_services/internal_documents/filesizes']).
      destroy_all
  end
end
