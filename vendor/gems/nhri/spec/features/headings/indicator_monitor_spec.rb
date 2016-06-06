require 'rails_helper'
require 'login_helpers'
#require 'navigation_helpers'
require_relative '../../helpers/headings/indicator_numeric_monitor_spec_helpers'
require_relative '../../helpers/headings/indicator_text_monitor_spec_helpers'
require_relative '../../helpers/headings/indicator_file_monitor_spec_helpers'
require_relative '../../helpers/headings/indicators_numeric_monitor_spec_setup_helpers'
require_relative '../../helpers/headings/indicator_text_monitor_spec_setup_helpers'
require_relative '../../helpers/headings/indicator_file_monitor_spec_setup_helpers'
require 'upload_file_helpers'

feature "monitors behaviour when indicator is configured to monitor with numeric format", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IndicatorNumericMonitorSpecHelpers
  include IndicatorsNumericMonitorSpecSetupHelpers

  scenario "add monitor" do
    expect(page).to have_selector('h4', :text => "Monitor: Numeric monitor explanation text")
    add_monitor.click
    sleep(0.2)
    expect(page).to have_selector("#new_monitor #monitor_value")
    fill_in(:monitor_value, :with =>555)
    set_date_to("August 19, 2025")
    save_monitor.click
    sleep(0.2)
    expect(Nhri::NumericMonitor.count).to eq 3
    expect(monitor_value.last.text).to eq "555"
    expect(monitor_date.last.text).to eq "Aug 19, 2025"
    hover_over_info_icon
    expect(author).to eq @user.first_last_name
  end

  scenario "closing the monitor modal also closes the add monitor fields" do
    add_monitor.click
    close_monitors_modal
    wait_for_modal_close
    show_monitors.click
    wait_for_modal_open
    expect(page).not_to have_selector("#new_monitor #monitor_value")
  end

  scenario "try to save monitor with blank value field" do
    add_monitor.click
    # skip setting the value
    #sleep(0.2)
    expect{ save_monitor.click; sleep(0.2) }.not_to change{Nhri::NumericMonitor.count}
    expect(monitor_value_error.first.text).to eq "Value cannot be blank"
  end

  scenario "try to save monitor with whitespace value field" do
    add_monitor.click
    fill_in(:monitor_value, :with => " ")
    save_monitor.click
    sleep(0.2)
    expect{ save_monitor.click; sleep(0.2) }.not_to change{Nhri::NumericMonitor.count}
    expect(monitor_value_error.first.text).to eq "Value cannot be blank"
  end

  scenario "monitors are rendered in chronological order" do
    expect(monitor_date.map(&:text)).to eq [ 4.days.ago.localtime.to_date.to_s(:short), 3.days.ago.localtime.to_date.to_s(:short)]
  end

  scenario "start to add, and then cancel" do
    add_monitor.click
    sleep(0.2)
    expect(page).to have_selector("#new_monitor #monitor_value")
    fill_in(:monitor_value, :with =>555)
    set_date_to("August 19, 2025")
    cancel_add
    expect(page).not_to have_selector("#new_monitor #monitor_value")
  end

  scenario "delete a monitor" do
    expect{ delete_monitor.first.click; wait_for_ajax }.to change{Nhri::NumericMonitor.count}.by(-1)
    close_monitors_modal
    wait_for_modal_close
    show_monitors.click
    wait_for_modal_open
    expect(number_of_numeric_monitors).to eq Nhri::NumericMonitor.count
  end

end


feature "monitors behaviour when indicator is configured to monitor with text format", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IndicatorTextMonitorSpecHelpers
  include IndicatorsTextMonitorSpecSetupHelpers

  scenario "add monitor" do
    expect(page).to have_selector('h4', :text => "Monitors: text format")
    add_monitor.click
    sleep(0.2)
    expect(page).to have_selector("#new_monitor #monitor_description")
    fill_in(:monitor_description, :with => "Some monitor description text")
    set_date_to("August 19, 2025")
    save_monitor.click
    sleep(0.2)
    expect(Nhri::TextMonitor.count).to eq 3
    expect(monitor_description.last.text).to eq "Some monitor description text"
    expect(monitor_date.last.text).to eq "Aug 19, 2025"
    hover_over_info_icon
    expect(author).to eq @user.first_last_name
  end

  scenario "closing the monitor modal also closes the add monitor fields" do
    add_monitor.click
    close_monitors_modal
    wait_for_modal_close
    show_monitors.click
    wait_for_modal_open
    expect(page).not_to have_selector("#new_monitor #monitor_description")
  end

  scenario "try to save monitor with blank description field" do
    add_monitor.click
    # skip setting the description
    sleep(0.2)
    expect{ save_monitor.click; sleep(0.2) }.not_to change{Nhri::TextMonitor.count}
    expect(monitor_description_error.first.text).to eq "Description cannot be blank"
  end

  scenario "try to save monitor with whitespace description field" do
    add_monitor.click
    fill_in(:monitor_description, :with => " ")
    save_monitor.click
    sleep(0.2)
    expect{ save_monitor.click; sleep(0.2) }.not_to change{Nhri::TextMonitor.count}
    expect(monitor_description_error.first.text).to eq "Description cannot be blank"
  end

  scenario "monitors are rendered in chronological order" do
    expect(monitor_date.map(&:text)).to eq [ 4.days.ago.localtime.to_date.to_s(:short), 3.days.ago.localtime.to_date.to_s(:short)]
  end

  scenario "start to add, and then cancel" do
    add_monitor.click
    sleep(0.2)
    expect(page).to have_selector("#new_monitor #monitor_description")
    fill_in(:monitor_description, :with =>555)
    set_date_to("August 19, 2025")
    cancel_add
    expect(page).not_to have_selector("#new_monitor #monitor_description")
  end

  scenario "delete a monitor" do
    expect{ delete_monitor.first.click; wait_for_ajax }.to change{Nhri::TextMonitor.count}.by(-1)
    close_monitors_modal
    wait_for_modal_close
    show_monitors.click
    wait_for_modal_open
    expect(number_of_text_monitors).to eq Nhri::TextMonitor.count
  end

  scenario "edit a monitor" do
    edit_monitor.click
    fill_in(:text_monitor_description, :with => "some new text")
    expect{edit_save_monitor.click; sleep(0.5)}.to change{Nhri::TextMonitor.all.first.description}.to "some new text"
  end

end

feature "monitors behaviour when indicator is configured to monitor with file format", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IndicatorFileMonitorSpecHelpers
  include IndicatorsFileMonitorSpecSetupHelpers
  include UploadFileHelpers

  scenario "update the file of the existing monitor" do
    expect(page).to have_selector('h4', :text => "Monitor: File")
    expect(page).to have_selector('.template-upload #filename', :text => Nhri::FileMonitor.first.original_filename)
    page.attach_file("monitor_file", upload_document, :visible => false)
    expect(page).to have_selector('#selected_file', :text => 'first_upload_file.pdf')
    expect{ save_monitor.click; sleep(0.2) }.not_to change{Nhri::FileMonitor.count}
    expect(Nhri::FileMonitor.first.original_filename).to eq 'first_upload_file.pdf'
    expect(page.find('#filename').text).to eq 'first_upload_file.pdf'
    hover_over_info_icon
    expect(file_size).to eq "7.76 KB"
    expect(author).to eq @user.first_last_name
  end

  scenario "update the file with unpermitted file type" do
    page.attach_file("monitor_file", upload_image, :visible => false)
    expect(page).to have_selector('#selected_file', :text => 'first_upload_image_file.png')
    expect(page).to have_css('#filetype_error', :text => "Unpermitted file type")
    expect{ save_monitor.click; sleep(0.3) }.not_to change{Nhri::FileMonitor.first.file_id}
    deselect_file
    expect(page).not_to have_selector('#selected_file', :text => 'first_upload_image_file.png')
    expect(page).not_to have_css('#filetype_error', :text => "Unpermitted file type")
    # after deselecting, should then be able to re-select a file:
    page.attach_file("monitor_file", upload_image, :visible => false)
    expect(page).to have_selector('#selected_file', :text => 'first_upload_image_file.png')
    expect(page).to have_css('#filetype_error', :text => "Unpermitted file type")
  end

  scenario "try to upload without selecting a file" do
    expect{ save_monitor.click; sleep(0.3) }.not_to change{Nhri::FileMonitor.first.file_id}
    expect(page).to have_css('#file_error', :text => "You must select a file")
  end

  scenario "update the file with file exceeding permitted file size" do
    page.attach_file("monitor_file", big_upload_document, :visible => false)
    expect(page).to have_selector('#selected_file', :text => 'big_upload_file.pdf')
    expect(page).to have_css('#filesize_error', :text => "File is too large")
    expect{ save_monitor.click; sleep(0.3) }.not_to change{Nhri::FileMonitor.first.file_id}
  end

  scenario "closing the monitor modal resets the selected file" do
    page.attach_file("monitor_file", upload_document, :visible => false)
    expect(page).to have_selector('#selected_file', :text => 'first_upload_file.pdf')
    close_monitors_modal
    wait_for_modal_close
    show_monitors.click
    wait_for_modal_open
    expect(page).not_to have_selector('#selected_file', :text => 'first_upload_file.pdf')
  end

  scenario "download the monitor file" do
    unless page.driver.instance_of?(Capybara::Selenium::Driver) # response_headers not supported, can't test download
      click_the_download_icon
      expect(page.response_headers['Content-Type']).to eq('application/msword')
      filename = Nhri::FileMonitor.first.original_filename
      expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"")
    else
      expect(1).to eq 1 # download not supported by selenium driver
    end
  end

end
