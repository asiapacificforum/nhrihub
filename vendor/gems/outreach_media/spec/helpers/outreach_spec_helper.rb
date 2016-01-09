require 'rspec/core/shared_context'

module OutreachSpecHelper
  extend RSpec::Core::SharedContext
  def resize_browser_window
    if page.driver.browser.respond_to?(:manage)
      page.driver.browser.manage.window.resize_to(1400,800) # b/c selenium driver doesn't seem to click when target is not in the view
    end
  end

  def edit_outreach_event
    page.all('.fa-pencil-square-o')
  end

  def add_outreach_event_button
    page.find('#add_outreach_event')
  end

  def edit_save
    page.find('.fa-check')
  end

  def chars_remaining
    page.find('.chars_remaining').text
  end

  def areas
    page.all("#outreach_events .outreach_event .expanded_info .description .area .name").map(&:text)
  end

  def subareas
    page.all("#outreach_events .outreach_event .expanded_info .description .subareas .subarea").map(&:text)
  end

  def expand_all_panels
    page.find('#outreach_events_controls #expand').click
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

  def cancel_outreach_event_add
    page.find('.form #edit_cancel').click
    sleep(0.2)
  end

  def edit_cancel
    page.find(".editable_container .basic_info .actions .fa-remove")
  end

  def delete_outreach_event
    page.find('.outreach_event .delete_icon').click
    sleep(0.4)
  end

  def outreach_events
    page.all('#outreach_events .outreach_event')
  end

  def click_note_icon
    page.find('#outreach_events .outreach_event .basic_info .actions .show_notes').click
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
    page.all("#deselect_file")[0].click
  end

  def saved_file
  end

  def click_the_download_icon
    page.find('#outreach_event_list .outreach_event #outreach_event_documents .fa-cloud-download').click
  end

  def click_the_link_icon
    page.find('.outreach_event .actions .fa-globe').click
  end

  def first_outreach_event_link
    OutreachEvent.first.outreach_event_link.gsub(/http/,'')
  end

  def delete_outreach_event_link_field
    fill_in("outreach_event_outreach_event_link", :with => "")
    # b/c setting the value by javascript (previous line) does not trigger the input event, as it would for a real user input
    if !page.driver.browser.is_a?(Capybara::Poltergeist::Browser)
      page.execute_script("event = new Event('input'); $('.outreach_event_link')[0].dispatchEvent(event)")
    end
  end

  def audience_type
    page.find('div.metric#audience_type div.value').text
  end

  def audience_name
    page.find('div.metric#audience_name div.value').text
  end

  def description
    page.find('div.metric#description div.value').text
  end

  def date
    page.find('.outreach_event .basic_info .date').text
  end

  def set_date_to(date_string)
    page.execute_script("outreach.findAllComponents('oe')[0].set('date', new Date(Date.parse('#{date_string}')))")
  end

  def selected_file
    page.find("#outreach_events #outreach_event_list #outreach_event_documents #selected_file").text
  end

  def deselect_first_file
    remove_file.click
  end

  def remove_file
    page.all('#deselect_file').last
  end
end
