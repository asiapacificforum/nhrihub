require 'rails_helper'
require 'login_helpers'
#require 'navigation_helpers'
require_relative '../../helpers/headings/indicator_numeric_monitor_spec_helpers'
require_relative '../../helpers/headings/indicators_numeric_monitor_spec_setup_helpers'

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
    show_monitors.click
    sleep(0.3) # css transition
    expect(page).not_to have_selector("#new_monitor #monitor_value")
  end

  scenario "try to save monitor with blank value field" do
    add_monitor.click
    # skip setting the value
    sleep(0.2)
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
    expect{ delete_monitor.first.click; sleep(0.2) }.to change{Nhri::NumericMonitor.count}.by(-1)
  end

end


feature "monitors behaviour when indicator is configured to monitor with text format", :js => true do
end

feature "monitors behaviour when indicator is configured to monitor with file format", :js => true do
end
