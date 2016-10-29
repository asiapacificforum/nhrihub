require 'rspec/core/shared_context'

module AdvisoryCouncilIssueSpecHelper
  extend RSpec::Core::SharedContext

  def edit_article
    page.all('.fa-pencil-square-o')
  end

  def add_article_button
    page.find('.add_article')
  end

  def edit_save
    page.find('.fa-check')
  end

  def chars_remaining
    page.find('.chars_remaining').text
  end

  def areas
    page.all("#advisory_council_issues .advisory_council_issue .expanded_info .description .area .name").map(&:text)
  end

  def subareas
    page.all("#advisory_council_issues .advisory_council_issue .expanded_info .description .subareas .subarea").map(&:text)
  end

  def expand_all_panels
    page.find('#advisory_council_issues_controls #expand').click
    sleep(0.3)
  end

  def people_affected
    page.find(".metric#affected_people_count .value").text
  end

  def positivity_rating
    page.find(".metric#positivity_rating .value").text
  end

  def violation_severity
    page.find(".metric#violation_severity .value").text
  end

  def cancel_article_add
    page.find('.form #edit_cancel').click
    sleep(0.2)
  end

  def edit_cancel
    page.find(".editable_container .basic_info .actions .fa-remove")
  end

  def click_delete_article
    page.find('.advisory_council_issue .delete_icon_sm').click
  end

  def advisory_council_issues
    page.all('#advisory_council_issues .advisory_council_issue')
  end

  def click_note_icon
    page.find('#advisory_council_issues .advisory_council_issue .basic_info .actions .show_notes').click
    sleep(0.4)
  end

  def click_add_note
    page.find('#add_note').click
    sleep(0.4)
  end

  def save_note
    page.find('#save_note').click
  end

  def upload_file_path(filename)
    CapybaraRemote.upload_file_path(page,filename)
  end

  def upload_document
    upload_file_path('first_upload_file.pdf')
  end

  def big_upload_document
    upload_file_path('big_upload_file.pdf')
  end

  def upload_image
    upload_file_path('first_upload_image_file.png')
  end

  def clear_file_attachment
    page.find("#deselect_file").click
  end

  def saved_file
  end

  def click_the_download_icon
    page.find('.advisory_council_issue .actions .fa-cloud-download').click
  end

  def click_the_link_icon
    page.find('.advisory_council_issue .actions .fa-globe').click
  end

  def first_article_link
    Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.article_link.gsub(/http/,'')
  end

  def delete_article_link_field
    fill_in("advisory_council_issue_article_link", :with => "")
    # b/c setting the value by javascript (previous line) does not trigger the input event, as it would for a real user input
    if !page.driver.browser.is_a?(Capybara::Poltergeist::Browser)
      page.execute_script("event = new Event('input'); $('.article_link')[0].dispatchEvent(event)")
    end
  end

  def select_first_planned_result
    sleep(0.1)
    page.all(".dropdown-submenu.planned_result").first.hover
  end

  def select_first_outcome
    sleep(0.1)
    page.all(".dropdown-submenu.outcome").first.hover
  end

  def select_first_activity
    sleep(0.1)
    page.all(".dropdown-submenu.activity").first.hover
  end
end
