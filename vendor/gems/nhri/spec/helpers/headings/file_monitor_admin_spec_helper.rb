require 'rspec/core/shared_context'

module FileMonitorAdminSpecHelper
  extend RSpec::Core::SharedContext

  def delete_title(text)
    page.find(:xpath, ".//div[@id='file_monitor']//tr[contains(td,'#{text}')]").find('a').click
  end

  def set_filesize(val)
    page.find('#file_monitor_filesize input#filesize').set(val)
  end

  def new_filetype_button
    page.find("#file_monitor_filetypes #new_file_monitor_filetype table button")
  end

  def set_filesize(val)
    page.find('#file_monitor_filesize input#filesize').set(val)
  end

  def delete_filetype(type)
    page.find(:xpath, ".//div[@id='file_monitor_filetypes']//tr[contains(td,'#{type}')]").find('a').click
  end
end
