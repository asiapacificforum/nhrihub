require 'rspec/core/shared_context'

module ProjectAdminSpecHelpers
  extend RSpec::Core::SharedContext

  def new_filetype_button
    page.find("#new_filetype table button")
  end

  def delete_filetype(type)
    page.find(:xpath, ".//tr[contains(td,'#{type}')]").find('a').click
  end

  def set_filesize(val)
    page.find('input#filesize').set(val)
  end
end
