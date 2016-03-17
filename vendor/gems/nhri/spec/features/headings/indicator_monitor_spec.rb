require 'rails_helper'
require 'login_helpers'
#require 'navigation_helpers'
require_relative '../../helpers/headings/indicator_monitor_spec_helpers'
require_relative '../../helpers/headings/indicators_monitor_spec_setup_helpers'

feature "monitors behaviour", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IndicatorMonitorSpecHelpers
  include IndicatorsMonitorSpecSetupHelpers

  scenario "add monitor with percentage format" do
    add_monitor.click
    sleep(0.2)
    expect(page).to have_selector("#new_monitor #monitor_description")
    fill_in(:monitor_description, :with => "nota bene")
    #select("percentage", :from => :monitor_format)
    #fill_in(:monitor_value, :with => 45)
    #set_date_to("August 19, 2015")
    save_monitor.click
    sleep(0.2)
    expect(Nhri::Indicator::Monitor.count).to eq 3
    expect(monitor_description.last.text).to eq "nota bene"
    expect(monitor_date.last.text).to eq Date.today.to_s(:short)
    hover_over_info_icon
    expect(author).to eq User.first.first_last_name
    expect(editor).to eq User.first.first_last_name
    expect(last_edited).to eq Date.today.to_s(:short)
  end

  #scenario "add monitor with integer format" do
    #add_monitor.click
    #sleep(0.2)
    #expect(page).to have_selector("#new_monitor #monitor_description")
    #fill_in(:monitor_description, :with => "nota bene")
    #select("percentage", :from => :monitor_format)
    #fill_in(:monitor_value, :with => 45)
    #set_date_to("August 19, 2015")
    #save_monitor.click
    #sleep(0.2)
    #expect(Nhri::Indicator::Monitor.count).to eq 3
    #expect(monitor_description.last.text).to eq "nota bene"
    #expect(monitor_date.last.text).to eq Date.today.to_s(:short)
    #hover_over_info_icon
    #expect(author).to eq User.first.first_last_name
    #expect(editor).to eq User.first.first_last_name
    #expect(last_edited).to eq Date.today.to_s(:short)
  #end

  #scenario "add monitor with description format" do
    #add_monitor.click
    #sleep(0.2)
    #expect(page).to have_selector("#new_monitor #monitor_description")
    #fill_in(:monitor_description, :with => "nota bene")
    #select("percentage", :from => :monitor_format)
    #fill_in(:monitor_value, :with => 45)
    #set_date_to("August 19, 2015")
    #save_monitor.click
    #sleep(0.2)
    #expect(Nhri::Indicator::Monitor.count).to eq 3
    #expect(monitor_description.last.text).to eq "nota bene"
    #expect(monitor_date.last.text).to eq Date.today.to_s(:short)
    #hover_over_info_icon
    #expect(author).to eq User.first.first_last_name
    #expect(editor).to eq User.first.first_last_name
    #expect(last_edited).to eq Date.today.to_s(:short)
  #end

  scenario "closing the monitor modal also closes the add monitor fields" do
    add_monitor.click
    close_monitors_modal
    show_monitors.click
    sleep(0.3) # css transition
    expect(page).not_to have_selector("#new_monitor #monitor_description")
  end

  scenario "closing the monitor modal also closes the edit monitor fields" do
  end

  scenario "try to save monitor with blank description field" do
    add_monitor.click
    # skip setting the description
    sleep(0.2)
    save_monitor.click
    sleep(0.2)
    expect(Nhri::Indicator::Monitor.count).to eq 2
    expect(monitor_description_error.first.text).to eq "Description cannot be blank"
  end

  scenario "try to save monitor with whitespace description field" do
    add_monitor.click
    fill_in(:monitor_description, :with => " ")
    save_monitor.click
    sleep(0.2)
    expect(Nhri::Indicator::Monitor.count).to eq 2
    expect(monitor_description_error.first.text).to eq "Description cannot be blank"
  end

  scenario "monitors are rendered in reverse chronological order" do
    expect(page).to have_selector("h4", :text => 'Monitors')
    expect(monitor_date.map(&:text)).to eq [3.days.ago.localtime.to_date.to_s(:short), 4.days.ago.localtime.to_date.to_s(:short)]
  end

  scenario "delete a monitor" do
    expect{ delete_monitor.first.click; sleep(0.2) }.to change{Nhri::Indicator::Monitor.count}.from(2).to(1)
  end

  scenario "edit a monitor" do
    edit_monitor.first.click
    fill_in('monitor_description', :with => "carpe diem")
    expect{ save_edit.click; sleep(0.2) }.to change{Nhri::Indicator::Monitor.first.description}.to("carpe diem")
    expect(page).to have_selector('#monitors .monitor .description .no_edit span', :text => 'carpe diem')
  end

  scenario "edit to blank description and cancel" do
    original_description = monitor_description.first.text
    edit_monitor.first.click
    fill_in('monitor_description', :with => " ")
    save_edit.click
    sleep(0.2)
    expect(edit_monitor_description_error.first.text).to eq "Description cannot be blank"
    cancel_edit.click
    expect(monitor_description.first.text).to eq original_description
    edit_monitor.first.click
    expect(page).not_to have_selector(".monitor .description.has-error")
  end

  scenario "edit and cancel without making changes" do
    original_description = monitor_description.first.text
    edit_monitor.first.click
    cancel_edit.click
    expect(monitor_description.first.text).to eq original_description
  end
end
