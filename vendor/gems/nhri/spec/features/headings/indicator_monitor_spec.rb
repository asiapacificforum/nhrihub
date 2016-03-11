require_relative '../../helpers/headings/indicator_monitor_spec_helpers'

feature "monitors behaviour" do
  include IndicatorMonitorSpecHelpers

  scenario "add monitor" do
    add_monitor.click
    sleep(0.2)
    expect(page).to have_selector("#new_monitor #monitor_text")
    fill_in(:monitor_text, :with => "nota bene")
    save_monitor.click
    sleep(0.2)
    expect(Monitor.count).to eq 3
    expect(monitor_text.first.text).to eq "nota bene"
    expect(monitor_date.first.text).to eq Date.today.to_s(:short)
    hover_over_info_icon
    expect(author).to eq User.first.first_last_name
    expect(editor).to eq User.first.first_last_name
    expect(last_edited).to eq Date.today.to_s(:short)
  end

  scenario "try to save monitor with blank text field" do
    add_monitor.click
    # skip setting the text
    sleep(0.2)
    save_monitor.click
    sleep(0.2)
    expect(Monitor.count).to eq 2
    expect(monitor_text_error.first.text).to eq "Text cannot be blank"
  end

  scenario "try to save monitor with whitespace text field" do
    add_monitor.click
    fill_in(:monitor_text, :with => " ")
    save_monitor.click
    sleep(0.2)
    expect(Monitor.count).to eq 2
    expect(monitor_text_error.first.text).to eq "Text cannot be blank"
  end

  scenario "monitors are rendered in reverse chronological order" do
    expect(page).to have_selector("h4", :text => 'Monitors')
    expect(monitor_date.map(&:text)).to eq [3.days.ago.localtime.to_date.to_s(:short), 4.days.ago.localtime.to_date.to_s(:short)]
  end

  scenario "delete a monitor" do
    expect{ delete_monitor.first.click; sleep(0.2) }.to change{Monitor.count}.from(2).to(1)
  end

  scenario "edit a monitor" do
    edit_monitor.first.click
    fill_in('monitor_text', :with => "carpe diem")
    expect{ save_edit.click; sleep(0.2) }.to change{Monitor.first.text}.to("carpe diem")
    expect(page).to have_selector('#monitors .monitor .text .no_edit span', :text => 'carpe diem')
  end

  scenario "edit to blank text and cancel" do
    original_text = monitor_text.first.text
    edit_monitor.first.click
    fill_in('monitor_text', :with => " ")
    save_edit.click
    sleep(0.2)
    expect(edit_monitor_text_error.first.text).to eq "Text cannot be blank"
    cancel_edit.click
    expect(monitor_text.first.text).to eq original_text
    edit_monitor.first.click
    expect(page).not_to have_selector(".monitor .text.has-error")
  end

  scenario "edit and cancel without making changes" do
    original_text = monitor_text.first.text
    edit_monitor.first.click
    cancel_edit.click
    expect(monitor_text.first.text).to eq original_text
  end
end
