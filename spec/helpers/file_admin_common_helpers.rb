require 'rspec/core/shared_context'

module FileAdminCommonHelpers
  extend RSpec::Core::SharedContext

  def new_filetype_button
    find("table button")
  end

  def set_filesize(val)
    page.find('input#filesize').set(val)
  end

  def delete_filetype(type)
    # the magic number 120, below, is seems to make the element scrolled into view
    # for both browser and phantom clients
    page.execute_script("scrollTo(0,$('#{filetypes_selector}').position().top - 120)")
    page.find(:xpath, ".//tr[contains(td,'#{type}')]").find('a').click
  end
end
