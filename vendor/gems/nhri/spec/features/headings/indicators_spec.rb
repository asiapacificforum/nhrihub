require 'rails_helper'
require 'login_helpers'
require_relative '../../helpers/headings/indicators_spec_helpers'
require_relative '../../helpers/headings/indicators_spec_setup_helpers'

feature "indicators behaviour", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IndicatorsSpecHelpers
  include IndicatorsSpecSetupHelpers

  it "should delete indicators" do
    expect(page).to have_selector("#indicators .indicator", :count => 2)
    expect{delete_indicator.click; confirm_deletion; wait_for_ajax}.to change{Nhri::Indicator.count}.by(-1)
    expect(page).to have_selector("#indicators .indicator", :count => 1)
  end

  it "should add valid multi-attribute indicator" do
    add_all_attribute_indicator
    wait_for_modal_open
    fill_in('indicator_title', :with => "Some arbitrary indicator title")
    select("Text", :from => "indicator_monitor_format")
    expect(page).not_to have_selector("#indicator_numeric_monitor_explanation")
    select("File", :from => "indicator_monitor_format")
    expect(page).not_to have_selector("#indicator_numeric_monitor_explanation")
    select("Numeric", :from => "indicator_monitor_format")
    expect(page).to have_selector("#indicator_numeric_monitor_explanation")
    fill_in("indicator_numeric_monitor_explanation", :with => "% of people who like me")
    expect{save_indicator.click; wait_for_ajax }.to change{Nhri::Indicator.all_attributes.count}.by(1).
                                                and change{ page.all("#indicators .all_attribute_indicators .indicator").length }.by(1)
    wait_for_modal_close
    indicator = Nhri::Indicator.last
    expect(indicator.monitor_format).to eq "numeric"
    expect(indicator.numeric_monitor_explanation).to eq "% of people who like me"
    expect(indicator.title).to eq "Some arbitrary indicator title"
    expect(indicator.heading_id).to eq Nhri::Heading.first.id
    expect(indicator.human_rights_attribute_id).to be_nil
    expect(page).not_to have_selector "#new_indicator_modal"
    expect(page).to have_selector('li.indicator', :text => "Some arbitrary indicator title")
    add_all_attribute_indicator # b/c there was a bug
    wait_for_modal_open
    expect(page.find('#indicator_monitor_format').value).to eq ""
    cancel_add
    wait_for_modal_close
    # b/c there was a bug
    expect{delete_indicator.click; confirm_deletion; wait_for_ajax}.to change{Nhri::Indicator.count}.by(-1)
    expect(page).not_to have_selector("#indicators .all_attribute_indicators .indicator")
  end

  it "should add single attribute indicator" do
    add_single_attribute_indicator
    wait_for_modal_open
    fill_in('indicator_title', :with => "Some arbitrary indicator title")
    select("Text", :from => "indicator_monitor_format")
    expect(page).not_to have_selector("#indicator_numeric_monitor_explanation")
    select("File", :from => "indicator_monitor_format")
    expect(page).not_to have_selector("#indicator_numeric_monitor_explanation")
    select("Numeric", :from => "indicator_monitor_format")
    expect(page).to have_selector("#indicator_numeric_monitor_explanation")
    fill_in("indicator_numeric_monitor_explanation", :with => "% of people who like me")
    expect{save_indicator.click; wait_for_ajax }.to change{Nhri::Indicator.count}.by(1)#.
                                                #and change{ page.all("#indicators .single_attribute_indicators .indicator").length }.by(1)
    debugger
    expect(1).to eq 1
  end

  it "should reset the new indicator form when add is canceled" do
    add_all_attribute_indicator
    fill_in('indicator_title', :with => "Some arbitrary indicator title")
    select("Numeric", :from => "indicator_monitor_format")
    fill_in("indicator_numeric_monitor_explanation", :with => "% of people who like me")
    cancel_add
    wait_for_modal_close
    expect(page).not_to have_selector "#new_indicator_modal"
    add_all_attribute_indicator
    expect(page).to have_selector("#new_indicator_modal #indicator_title", :text => "")
    expect(page.find("#new_indicator_modal #indicator_monitor_format").value).to eq ""
  end

  it "should not add invalid indicator" do
    add_all_attribute_indicator
    expect{save_indicator.click; wait_for_ajax}.not_to change{Nhri::Indicator.count}
    expect(page).to have_selector('#title_error', :text => "Title can't be blank")
    expect(page).to have_selector('#monitor_format_error', :text => "You must select a monitor format")
    select("Numeric", :from => "indicator_monitor_format")
    expect(page).not_to have_selector('#monitor_format_error', :text => "You must select a monitor format")
    save_indicator.click
    expect(page).to have_selector('#numeric_monitor_explanation_error', :text => "Explanation text can't be blank")
    fill_in("indicator_numeric_monitor_explanation", :with => "% of people who like me")
    expect(page).not_to have_selector('#numeric_monitor_explanation_error', :text => "Explanation text can't be blank")
    fill_in("indicator_title", :with => "Some arbitrary indicator title")
    expect(page).not_to have_selector('#title_error', :text => "Title can't be blank")
    expect{save_indicator.click; wait_for_ajax}.to change{Nhri::Indicator.count}.by 1
  end

  it "should edit indicators" do
    edit_first_indicator
    expect(page).to have_selector("#indicator_numeric_monitor_explanation")
    expect(page.find('#indicator_numeric_monitor_explanation').value).to eq 'percentage of dogs that like cats'
    fill_in('indicator_title', :with => "Changed title")
    select("Text", :from => "indicator_monitor_format")
    expect(page).not_to have_selector("#indicator_numeric_monitor_explanation")
    expect{save_indicator.click; wait_for_ajax}.not_to change{Nhri::Indicator.count}
    indicator = Nhri::Indicator.first
    expect(indicator.monitor_format).to eq "text"
    expect(indicator.numeric_monitor_explanation).to be_blank
    expect(indicator.title).to eq "Changed title"
    expect(page).not_to have_selector "#new_indicator_modal"
    expect(page).to have_selector('li.indicator', :text => "Changed title")
  end

  it "should show a warning when an indicator is edited to blank description" do
    edit_first_indicator
    fill_in('indicator_title', :with => "")
    expect{save_indicator.click; wait_for_ajax}.not_to change{Nhri::Indicator.count}
    expect(page).to have_selector('#title_error', :text => "Title can't be blank")
  end

end

