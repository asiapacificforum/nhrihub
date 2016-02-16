require 'rspec/core/shared_context'

module IccAdminSpecHelper
  extend RSpec::Core::SharedContext

  def new_doc_group_button
    page.find("#new_doc_group table button")
  end

  def delete_title(text)
    page.find(:xpath, ".//tr[contains(td,'#{text}')]").find('a').click
  end

  def set_filesize(val)
    page.find('input#filesize').set(val)
  end

  def new_filetype_button
    page.find("#new_filetype table button")
  end

  def set_filesize(val)
    page.find('input#filesize').set(val)
  end

  def delete_filetype(type)
    page.find(:xpath, ".//tr[contains(td,'#{type}')]").find('a').click
  end
end
