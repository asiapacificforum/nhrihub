require 'rspec/core/shared_context'

module TermsOfReferenceAdminSpecHelper
  extend RSpec::Core::SharedContext

  def delete_title(text)
    #page.find(:xpath, ".//tr[contains(td,'#{text}')]").find('a').click
    page.find(:xpath, ".//div[@id='terms_of_reference_version']//tr[contains(td,'#{text}')]").find('a').click
  end

  def set_filesize(val)
    page.find('#terms_of_reference_version_filesize input#filesize').set(val)
  end

  def new_filetype_button
    page.find("#terms_of_reference_version_filetypes #new_terms_of_reference_version_filetype table button")
  end

  def set_filesize(val)
    page.find('#terms_of_reference_version_filesize input#filesize').set(val)
  end

  def delete_filetype(type)
    #page.find(:xpath, ".//tr[contains(td,'#{type}')]").find('a').click
    page.find(:xpath, ".//div[@id='terms_of_reference_version_filetypes']//tr[contains(td,'#{type}')]").find('a').click
  end
end
