require 'rspec/core/shared_context'

module AdvisoryCouncilMinutesAdminSpecHelper
  extend RSpec::Core::SharedContext

  def delete_title(text)
    page.find(:xpath, ".//div[@id='advisory_council_minutes']//tr[contains(td,'#{text}')]").find('a').click
  end

  def set_filesize(val)
    page.find('#advisory_council_minutes_filesize input#filesize').set(val)
  end

  def new_filetype_button
    page.find("#advisory_council_minutes_filetypes #new_advisory_council_minutes_filetype table button")
  end

  def set_filesize(val)
    page.find('#advisory_council_minutes_filesize input#filesize').set(val)
  end

  def delete_filetype(type)
    page.execute_script("scrollTo(0,$('#advisory_council_minutes_filetypes').position().top - 40)")
    page.find(:xpath, ".//div[@id='advisory_council_minutes_filetypes']//tr[contains(td,'#{type}')]").find('a').click
  end
end
