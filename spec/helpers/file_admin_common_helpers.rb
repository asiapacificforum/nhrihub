require 'rspec/core/shared_context'

module FileAdminCommonHelpers
  extend RSpec::Core::SharedContext

  def flash_message
    page.find(".message_block").text
  end

  def new_filetype_button
    find("table button")
  end

  def set_filesize(val)
    page.find('input#filesize').set(val)
  end

  def delete_filetype(type)
    page.execute_script("scrollTo(0,$('#{filetypes_selector}').position().top - 80)")
    page.find(:xpath, ".//tr[contains(td,'#{type}')]").find('a').click
  end
end
