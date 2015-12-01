require 'rspec/core/shared_context'

module OutreachSpecHelper
  extend RSpec::Core::SharedContext
  def resize_browser_window
    if page.driver.browser.respond_to?(:manage)
      page.driver.browser.manage.window.resize_to(1400,800) # b/c selenium driver doesn't seem to click when target is not in the view
    end
  end

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
    page.all("#media_appearances .media_appearance .expanded_info .description .area .name").map(&:text)
  end

  def subareas
    page.all("#media_appearances .media_appearance .expanded_info .description .subareas .subarea").map(&:text)
  end

  def expand_all_panels
    page.find('#media_appearances_controls #expand').click
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

  def delete_article
    page.find('.media_appearance .delete_icon').click
    sleep(0.4)
  end

  def media_appearances
    page.all('#media_appearances .media_appearance')
  end

  def click_note_icon
    page.find('#media_appearances .media_appearance .basic_info .actions .show_notes').click
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
    page.find('.media_appearance .actions .fa-cloud-download').click
  end

  def click_the_link_icon
    page.find('.media_appearance .actions .fa-globe').click
  end

  def first_article_link
    MediaAppearance.first.article_link.gsub(/http/,'')
  end

  def delete_article_link_field
    fill_in("media_appearance_article_link", :with => "")
    # b/c setting the value by javascript (previous line) does not trigger the input event, as it would for a real user input
    if !page.driver.browser.is_a?(Capybara::Poltergeist::Browser)
      page.execute_script("event = new Event('input'); $('.article_link')[0].dispatchEvent(event)")
    end
  end
end
