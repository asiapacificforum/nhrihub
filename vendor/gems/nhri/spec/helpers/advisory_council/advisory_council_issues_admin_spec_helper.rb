require 'rspec/core/shared_context'

module AdvisoryCouncilIssuesAdminSpecHelper
  extend RSpec::Core::SharedContext

  def delete_title(text)
    page.find(:xpath, ".//div[@id='advisory_council_issues']//tr[contains(td,'#{text}')]").find('a').click
  end

  def set_filesize(val)
    page.find('#advisory_council_issues_filesize input#filesize').set(val)
  end

  def new_filetype_button
    page.find("#advisory_council_issues_filetypes #new_advisory_council_issues_filetype table button")
  end

  def set_filesize(val)
    page.find('#advisory_council_issues_filesize input#filesize').set(val)
  end

  def delete_filetype(type)
    page.find(:xpath, ".//div[@id='advisory_council_issues_filetypes']//tr[contains(td,'#{type}')]").find('a').click
  end
end
