require 'rspec/core/shared_context'

module AdvisoryCouncilMinutesSpecHelper
  def first_edit_icon
    page.all('.advisory_council_minutes .icon .no_edit i.fa-pencil-square-o').first
  end

  def edit_save_icon
    page.all('.advisory_council_minutes .icon .edit i.fa-check').first
  end

  def first_delete_icon
    page.all('.advisory_council_minutes .icon i.fa-trash-o').first
  end

  def click_the_download_icon
    page.all('.advisory_council_minutes .icon i.fa-cloud-download').first.click
  end
end
