require 'rspec/core/shared_context'

module CorporateServicesAdminSpecHelpers
  extend RSpec::Core::SharedContext

  def new_filetype_button
    page.find("#new_filetype table button")
  end

  def set_filesize(val)
    page.find('input#filesize').set(val)
  end

  def delete_filetype(type)
    page.find(:xpath, ".//tr[contains(td,'#{type}')]").find('a').click
  end

  def remove_add_delete_fileconfig_permissions
    ActionRole.
      joins(:action => :controller).
      where('actions.action_name' => ['create', 'destroy', 'update'],
            'controllers.controller_name' => ['corporate_services/internal_documents/filetypes','corporate_services/internal_documents/filesizes']).
      destroy_all
  end
end
