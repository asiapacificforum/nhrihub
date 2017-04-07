require 'reminders_spec_common_helpers'
RSpec.shared_examples "has performance indicator association" do
  include PerformanceIndicatorHelpers

  scenario "add a performance indicator link" do
    edit_first_item
    select_performance_indicators.click
    select_first_performance_indicator
    pi = PerformanceIndicator.first
    expect(page).to have_selector("#performance_indicators .selected_performance_indicator", :text => pi.indexed_description )
    remove_last_indicator.click
    expect(page).not_to have_selector("#performance_indicators .selected_performance_indicator", :text => pi.indexed_description )
    select_performance_indicators.click
    select_first_performance_indicator
    expect{edit_save}.to change{@model.first.performance_indicator_ids.count}.by(1)
  end

  it "should remove performance indicator from the list during adding" do
    add_new_item
    pi = add_a_performance_indicator
    expect(page).to have_selector("#performance_indicators .selected_performance_indicator", :text => pi.indexed_description)
    remove_first_indicator.click
    wait_for_ajax
    expect(page).not_to have_selector("#performance_indicators .selected_performance_indicator", :text => pi.indexed_description)
  end

  it "should prevent adding duplicate performance indicators" do
    add_new_item
    pi = add_a_performance_indicator
    expect(page).to have_selector("#performance_indicators .selected_performance_indicator", :text => pi.indexed_description)
    # try a duplicate
    pi = add_a_performance_indicator
    expect(page).to have_selector("#performance_indicators .selected_performance_indicator", :text => pi.indexed_description, :count => 1)
  end

  it "should edit an item and remove performance indicators" do
    edit_first_item
    expect{ remove_first_indicator.click; wait_for_ajax }.to change{ @association.count }.by(-1).
      and change{ page.all('.selected_performance_indicator').count }.by(-1)
  end

  it "should edit an item and add performance indicators" do
    edit_first_item
    pi = add_a_unique_performance_indicator
    expect(page).to have_selector("#performance_indicators .selected_performance_indicator", :text => pi.indexed_description)
    # just make sure it can be removed with the 'x' icon
    remove_last_indicator.click # it's the one that was just added
    sleep(0.1)
    expect(page).not_to have_selector("#performance_indicators .selected_performance_indicator", :text => pi.indexed_description)
    add_a_unique_performance_indicator
    expect{ edit_save }.to change{ @model.first.performance_indicators.count }.from(3).to(4)
  end

  it "should not permit duplicate performance indicator associations to be added when editing" do
    edit_first_item
    add_a_performance_indicator
    expect(page).to have_selector("#performance_indicators .selected_performance_indicator", :count => 3)
  end
end

