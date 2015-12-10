require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/outreach_spec_helper'
require_relative '../../helpers/outreach_setup_helper'


feature "show outreach archive", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include OutreachSpecHelper
  include OutreachSetupHelper

  before do
    setup_impact_ratings
    setup_areas
    FactoryGirl.create(:outreach_event, :hr_area, :impact_rating => ImpactRating.first, :reminders=>[FactoryGirl.create(:reminder, :outreach_event)] )
    resize_browser_window
    visit outreach_media_outreach_events_path(:en)
  end

  scenario "lists outreach events" do
    expect(page_heading).to eq "Outreach Events"
    expect(page).to have_selector("#outreach_events .outreach_event", :count => 1)
  end
end

feature "create a new outreach event", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include OutreachSpecHelper
  include OutreachSetupHelper

  before do
    setup_impact_ratings
    setup_areas
    setup_file_constraints
    setup_audience_types
    resize_browser_window
    visit outreach_media_outreach_events_path(:en)
    add_outreach_event_button.click
  end

  scenario "without errors" do
    #TITLE
    fill_in("outreach_event_title", :with => "My new outreach event title")
    expect(chars_remaining).to eq "You have 73 characters left"
    expect(page).not_to have_selector("input#people_affected", :visible => true)
    #expect(page.find('#outreach_event_subarea_ids_1')).to be_disabled # defer until ractive 0.8.0 is stable
    #expect(page.find('#outreach_event_subarea_ids_2')).to be_disabled
    #expect(page.find('#outreach_event_subarea_ids_3')).to be_disabled
    #expect(page.find('#outreach_event_subarea_ids_4')).to be_disabled
    #expect(page.find('#outreach_event_subarea_ids_5')).to be_disabled
    # AREA
    check("Human Rights")
    #SUBAREA
    check("outreach_event_subarea_ids_1")
    expect(page).to have_selector("input#people_affected", :visible => true)
    #AREA
    check("Good Governance")
    #SUBAREA
    check("CRC")
    #PEOPLE AFFECTED
    fill_in('people_affected', :with => " 100000 ")
    #AUDIENCE_TYPE
    select('Police', :from => :audience_type)
    #AUDIENCE NAME
    fill_in('audience_name', :with => "City of Monrovia PD")
    #PARTIPANT COUNT
    fill_in('participant_count', :with => "988")
    #DESCRIPTION
    fill_in('description', :with => "Briefing on progress to date and plans for the immediate and long-term future")
    #FILE!!!
    page.attach_file("outreach_event_file", upload_document, :visible => false)
    expect{edit_save.click; sleep(0.5)}.to change{OutreachEvent.count}.from(0).to(1).
                                        and change{OutreachEventDocument.count}.from(0).to(1)
    oe = OutreachEvent.first
    expect(oe.affected_people_count).to eq 100000
    expect(oe.audience_type.text).to eq "Police"
    expect(oe.audience_name).to eq "City of Monrovia PD"
    expect(oe.description).to match /Briefing/
    sleep(0.4)
    expect(page).to have_selector("#outreach_events .outreach_event", :count => 1)
    expect(page.find("#outreach_events .outreach_event .basic_info .title").text).to eq "My new outreach event title"
    expand_all_panels
    expect(areas).to include "Human Rights"
    expect(areas).to include "Good Governance"
    expect(subareas).to include "CRC"
    expect(people_affected.gsub(/,/,'')).to eq "100000" # b/c phantomjs does not have a toLocaleString() method
    expect(audience_type).to eq "Police"
    expect(audience_name).to eq "City of Monrovia PD"
    expect(description).to match /Briefing/
  end

  xscenario "upload outreach event from file" do
    fill_in("outreach_event_title", :with => "My new outreach event title")
    page.attach_file("outreach_event_file", upload_document, :visible => false)
    expect{edit_save.click; sleep(0.4)}.to change{OutreachEvent.count}.from(0).to(1)
    expect(page).to have_css("#outreach_events .outreach_event", :count => 1)
    doc = OutreachEvent.last
    expect( doc.title ).to eq "My new outreach event title"
    expect( doc.filesize ).to be > 0 # it's the best we can do, if we don't know the file size
    expect( doc.original_filename ).to eq 'first_upload_file.pdf'
    expect( doc.lastModifiedDate ).to be_a ActiveSupport::TimeWithZone # it's a weak assertion!
    expect( doc.original_type ).to eq "application/pdf"
  end

  scenario "repeated adds" do # b/c there was a bug!
    fill_in("outreach_event_title", :with => "My new outreach event title")
    expect(chars_remaining).to eq "You have 73 characters left"
    expect{edit_save.click; sleep(0.4)}.to change{OutreachEvent.count}.from(0).to(1)
    sleep(0.4)
    expect(page).to have_selector("#outreach_events .outreach_event", :count => 1)
    expect(page.all("#outreach_events .outreach_event .basic_info .title").first.text).to eq "My new outreach event title"
    add_outreach_event_button.click
    fill_in("outreach_event_title", :with => "My second new outreach event title")
    expect{edit_save.click; sleep(0.4)}.to change{OutreachEvent.count}.from(1).to(2)
    sleep(0.4)
    expect(page).to have_selector("#outreach_events .outreach_event", :count => 2)
    expect(page.all("#outreach_events .outreach_event .basic_info .title")[0].text).to eq "My second new outreach event title"
    expect(page.all("#outreach_events .outreach_event .basic_info .title")[1].text).to eq "My new outreach event title"
  end

  scenario "start creating and cancel" do
    cancel_outreach_event_add
    expect(page).not_to have_selector('.form #outreach_event_title')
  end
end

feature "attempt to save with errors", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include OutreachSpecHelper
  include OutreachSetupHelper

  before do
    setup_impact_ratings
    setup_areas
    setup_file_constraints
    resize_browser_window
    visit outreach_media_outreach_events_path(:en)
    add_outreach_event_button.click
  end

  scenario "title is blank" do
    expect{edit_save.click; sleep(0.4)}.not_to change{OutreachEvent.count}
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in("outreach_event_title", :with => "m")
    expect(page).not_to have_selector("#title_error", :visible => true)
  end

  feature "file is not included" do
    before do
      fill_in("outreach_event_title", :with => "My new outreach event title")
      expect{edit_save.click; sleep(0.4)}.not_to change{OutreachEvent.count}
      expect(page).to have_selector('#outreach_event_error', :text => "A file must be included")
    end

    xscenario "remove error by adding a file" do
      page.attach_file("outreach_event_file", upload_document, :visible => false)
      expect(page).not_to have_selector('#outreach_event_error', :text => "A file must be included")
    end
  end

  xscenario "upload an unpermitted file type and cancel" do
    fill_in("outreach_event_title", :with => "My new outreach event title")
    page.attach_file("outreach_event_file", upload_image, :visible => false)
    expect(page).to have_css('#filetype_error', :text => "File type not allowed")
    expect{edit_save.click; sleep(0.5)}.not_to change{OutreachEvent.count}
    page.find(".outreach_event i#edit_cancel").click
    expect(page).not_to have_css("#outreach_events .outreach_event")
  end

  xscenario "upload a file that exceeds size limit" do
    page.attach_file("outreach_event_file", big_upload_document, :visible => false)
    expect(page).to have_css('#filesize_error', :text => "File is too large")
    page.find(".outreach_event i#edit_cancel").click
    expect(page).not_to have_css("#outreach_events .outreach_event")
  end
end

feature "when there are existing outreach events", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include OutreachSpecHelper
  include OutreachSetupHelper

  feature "and existing outreach event has file attachment" do
    before do
      setup_database
      setup_file_constraints
      resize_browser_window
      visit outreach_media_outreach_events_path(:en)
    end

    xscenario "delete an outreach event" do
      saved_file_path = File.join('tmp','uploads','store',OutreachEvent.first.file.id)
      expect(File.exists?(saved_file_path)).to eq true
      expect{ delete_outreach_event }.to change{OutreachEvent.count}.from(1).to(0)
      expect(outreach_events.length).to eq 0
      expect(File.exists?(saved_file_path)).to eq false
    end

    scenario "edit an outreach event without introducing errors" do
      edit_outreach_event[0].click
      fill_in("outreach_event_title", :with => "My new outreach event title")
      expect(chars_remaining).to eq "You have 73 characters left"
      uncheck("Human Rights")
      check("outreach_event_subarea_ids_1")
      expect(page).to have_selector("input#people_affected", :visible => true)
      check("Good Governance")
      check("CRC")
      debugger
      fill_in('people_affected', :with => " 100000 ")
      debugger
      expect{edit_save.click; sleep(0.4)}.to change{OutreachEvent.first.title}
      expect(OutreachEvent.first.area_ids).to eql [2]
      sleep(0.4)
      expect(page.all("#outreach_events .outreach_event .basic_info .title").first.text).to eq "My new outreach event title"
      expect(areas).not_to include "Human Rights"
      expect(areas).to include "Good Governance"
    end

    xscenario "edit an outreach event and upload a different file" do
      edit_outreach_event[0].click
      expect(page.find('#selected_file_container').text).not_to be_blank
      previous_file_id = page.evaluate_script("media.findAllComponents('ma')[0].get('file_id')")
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq true
      page.attach_file("outreach_event_file", upload_document, :visible => false)
      edit_save.click
      sleep(0.4)
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq false
      new_file_id = page.evaluate_script("media.findAllComponents('ma')[0].get('file_id')")
      expect(File.exists?(File.join('tmp','uploads','store',new_file_id))).to eq true
    end

    scenario "edit an outreach event and add title error" do
      edit_outreach_event[0].click
      fill_in("outreach_event_title", :with => "")
      expect(chars_remaining).to eq "You have 100 characters left"
      expect{edit_save.click; sleep(0.4)}.not_to change{OutreachEvent.count}
      expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
      fill_in("outreach_event_title", :with => "m")
      expect(page).not_to have_selector("#title_error", :visible => true)
    end

    xscenario "edit an outreach event and add file error" do
      edit_outreach_event[0].click
      page.attach_file("outreach_event_file", upload_image, :visible => false)
      expect(page).to have_css('#filetype_error', :text => "File type not allowed")
      clear_file_attachment
      expect(page).to have_selector('#outreach_event_error', :text => "A file or link must be included")
      edit_cancel.click
      sleep(0.2)
      edit_outreach_event[0].click
      expect(page).not_to have_selector('#outreach_event_error', :text => "A file or link must be included")
    end

    scenario "edit an outreach event, add errors, and cancel" do
      edit_outreach_event[0].click
      fill_in("outreach_event_title", :with => "")
      expect(chars_remaining).to eq "You have 100 characters left"
      expect{edit_save.click; sleep(0.4)}.not_to change{OutreachEvent.count}
      expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
      edit_cancel.click
      sleep(0.2)
      edit_outreach_event[0].click
      expect(page).not_to have_selector("#title_error", :visible => true)
    end

    scenario "edit an outreach event and cancel without saving" do
      original_outreach_event = OutreachEvent.first
      edit_outreach_event[0].click
      fill_in("outreach_event_title", :with => "My new outreach event title")
      expect(chars_remaining).to eq "You have 73 characters left"
      uncheck("Human Rights")
      check("outreach_event_subarea_ids_1")
      expect(page).to have_selector("input#people_affected", :visible => true)
      check("Good Governance")
      check("CRC")
      fill_in('people_affected', :with => " 100000 ")
      expect{edit_cancel.click; sleep(0.4)}.not_to change{OutreachEvent.first.title}
      expect(page.all("#outreach_events .outreach_event .basic_info .title").first.text).to eq original_outreach_event.title
      expand_all_panels
      expect(areas).to include "Human Rights"
      expect(areas).not_to include "Good Governance"
    end
  end
end

feature "enforce single user add or edit action", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include OutreachSpecHelper
  include OutreachSetupHelper

  before do
    setup_database
    add_a_second_outreach_event
    resize_browser_window
    visit outreach_media_outreach_events_path(:en)
  end

  scenario "user tries to edit two outreach events" do
    edit_outreach_event[0].click
    expect(page).to have_selector('.title .edit.in', :count => 1)
    edit_outreach_event[0].click # not the same one as before, it isn't visible any more, this is another one
    expect(page).to have_selector('.title .edit.in', :count => 1)
  end

  scenario "user tries to edit while adding" do
    add_outreach_event_button.click
    expect(page).to have_selector('.row.outreach_event.well.well-sm.form.template-upload')
    edit_outreach_event[0].click
    expect(page).to have_selector('.title .edit.in', :count => 1)
    expect(page).not_to have_selector('.row.outreach_event.well.well-sm.form.template-upload')
  end

  scenario "user tries to add while editing" do
    edit_outreach_event[0].click
    expect(page).to have_selector('.title .edit.in', :count => 1)
    add_outreach_event_button.click
    expect(page).not_to have_selector('.title .edit.in', :count => 1)
    expect(page).to have_selector('.row.outreach_event.well.well-sm.form.template-upload')
  end
end

feature "view attachments", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include OutreachSpecHelper
  include OutreachSetupHelper

  xscenario "download attached file" do
    unless page.driver.instance_of?(Capybara::Selenium::Driver) # response_headers not supported, can't test download
      setup_database
      @doc = OutreachEvent.first
      visit outreach_media_outreach_events_path(:en)
      click_the_download_icon
      expect(page.response_headers['Content-Type']).to eq('application/pdf')
      filename = @doc.original_filename
      expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"")
    else
      expect(1).to eq 1 # download not supported by selenium driver
    end
  end
end
