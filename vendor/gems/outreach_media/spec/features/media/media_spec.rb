require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/media_spec_helper'
require_relative '../../helpers/media_setup_helper'
require 'media_issues_common_helpers'


feature "show media archive", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaIssuesCommonHelpers
  include MediaSpecHelper
  include MediaSetupHelper

  before do
    setup_positivity_ratings
    setup_file_constraints
    setup_areas
    FactoryGirl.create(:media_appearance, :hr_area, :positivity_rating => PositivityRating.first, :reminders=>[FactoryGirl.create(:reminder, :media_appearance)] )
    resize_browser_window
    visit media_appearances_path(:en)
  end

  scenario "lists media appearances" do
    expect(page_heading).to eq "Media Archive"
    expect(page).to have_selector("#media_appearances .media_appearance", :count => 1)
  end
end

feature "create a new article", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaIssuesCommonHelpers
  include MediaSpecHelper
  include MediaSetupHelper

  before do
    setup_strategic_plan
    setup_positivity_ratings
    setup_areas
    setup_violation_severities
    setup_file_constraints
    setup_strategic_plan
    resize_browser_window
    visit media_appearances_path(:en)
    add_article_button.click
  end

  scenario "without file and without errors" do
    fill_in("media_appearance_title", :with => "My new article title")
    expect(chars_remaining).to eq "You have 80 characters left"
    expect(page).not_to have_selector("input#people_affected", :visible => true)
    #expect(page.find('#media_appearance_subarea_ids_1')).to be_disabled # defer until ractive 0.8.0 is stable
    #expect(page.find('#media_appearance_subarea_ids_2')).to be_disabled
    #expect(page.find('#media_appearance_subarea_ids_3')).to be_disabled
    #expect(page.find('#media_appearance_subarea_ids_4')).to be_disabled
    #expect(page.find('#media_appearance_subarea_ids_5')).to be_disabled
    check("Human Rights")
    check("media_appearance_subarea_ids_1")
    expect(page).to have_selector("input#people_affected", :visible => true)
    check("Good Governance")
    check("CRC")
    fill_in('people_affected', :with => " 100000 ")
    select('3: Has no bearing on the office', :from => 'Positivity rating')
    select('4: Serious', :from => 'Violation severity')
    fill_in('media_appearance_article_link', :with => "http://www.example.com")
    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    select_first_performance_indicator
    pi = PerformanceIndicator.first
    expect(page).to have_selector("#performance_indicators .selected_performance_indicator", :text => pi.indexed_description )
    expect{page.execute_script("scrollTo(0,0)"); add_save}.to change{MediaAppearance.count}.from(0).to(1)
    ma = MediaAppearance.first
    expect(ma.performance_indicator_ids).to eq [pi.id]
    expect(ma.affected_people_count).to eq 100000 # b/c this attribute now returns a hash!
    sleep(0.4)
    expect(page).to have_selector("#media_appearances .media_appearance", :count => 1)
    expect(page.find("#media_appearances .media_appearance .basic_info .title").text).to eq "My new article title"
    expand_all_panels
    expect(areas).to include "Human Rights"
    expect(areas).to include "Good Governance"
    expect(subareas).to include "CRC"
    expect(positivity_rating).to eq "3: Has no bearing on the office"
    expect(violation_severity).to eq "4: Serious"
    expect(people_affected.gsub(/,/,'')).to eq "100000" # b/c phantomjs does not have a toLocaleString() method
  end

  scenario "upload article from file" do
    fill_in("media_appearance_title", :with => "My new article title")
    page.execute_script("collection.set('document_target',collection.findComponent('collectionItem'))")
    page.attach_file("primary_file", upload_document, :visible => false)
    expect{add_save}.to change{MediaAppearance.count}.from(0).to(1)
    expect(page).to have_css("#media_appearances .media_appearance", :count => 1)
    doc = MediaAppearance.last
    expect( doc.title ).to eq "My new article title"
    expect( doc.filesize ).to be > 0 # it's the best we can do, if we don't know the file size
    expect( doc.original_filename ).to eq 'first_upload_file.pdf'
    expect( doc.lastModifiedDate ).to be_a ActiveSupport::TimeWithZone # it's a weak assertion!
    expect( doc.original_type ).to eq "application/pdf"
  end

  scenario "repeated adds" do # b/c there was a bug!
    fill_in("media_appearance_title", :with => "My new article title")
    expect(chars_remaining).to eq "You have 80 characters left"
    fill_in('media_appearance_article_link', :with => "http://www.example.com")
    expect{add_save}.to change{MediaAppearance.count}.from(0).to(1)
    sleep(0.4)
    expect(page).to have_selector("#media_appearances .media_appearance", :count => 1)
    expect(page.all("#media_appearances .media_appearance .basic_info .title").first.text).to eq "My new article title"
    add_article_button.click
    fill_in("media_appearance_title", :with => "My second new article title")
    fill_in('media_appearance_article_link', :with => "http://www.example.com")
    expect{add_save}.to change{MediaAppearance.count}.from(1).to(2)
    sleep(0.4)
    expect(page).to have_selector("#media_appearances .media_appearance", :count => 2)
    expect(page.all("#media_appearances .media_appearance .basic_info .title")[0].text).to eq "My second new article title"
    expect(page.all("#media_appearances .media_appearance .basic_info .title")[1].text).to eq "My new article title"
  end

  scenario "start creating and cancel" do
    add_cancel
    expect(page).not_to have_selector('.form #media_appearance_title')
  end
end

feature "attempt to save with errors", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaIssuesCommonHelpers
  include MediaSpecHelper
  include MediaSetupHelper

  before do
    setup_positivity_ratings
    setup_areas
    setup_violation_severities
    setup_file_constraints
    resize_browser_window
    visit media_appearances_path(:en)
    add_article_button.click
  end

  scenario "title is blank" do
    sleep(0.8)
    expect(page).to have_selector('label', :text => 'Enter web link') # to control timing
    expect{add_save}.not_to change{MediaAppearance.count}
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in("media_appearance_title", :with => "m")
    expect(page).not_to have_selector("#title_error", :visible => true)
  end

  feature "neither link nor file is included" do
    before do
      fill_in("media_appearance_title", :with => "My new article title")
      expect{add_save}.not_to change{MediaAppearance.count}
      expect(page).to have_selector('#attachment_error', :text => "A file or link must be included")
    end

    scenario "remove error by adding a file" do
      page.execute_script("collection.set('document_target',collection.findComponent('collectionItem'))")
      page.attach_file("primary_file", upload_document, :visible => false)
      expect(page).not_to have_selector('#attachment_error', :text => "A file or link must be included")
    end

    scenario "remove error by adding a link" do
      fill_in("media_appearance_article_link", :with => "h")
      expect(page).not_to have_selector('#attachment_error', :text => "A file or link must be included")
    end
  end

  feature "both link and file are included" do
    before do
      fill_in("media_appearance_title", :with => "My new article title")
      page.execute_script("collection.set('document_target',collection.findComponent('collectionItem'))")
      page.attach_file("primary_file", upload_document, :visible => false)
      fill_in("media_appearance_article_link", :with => "h")
      expect{add_save}.not_to change{MediaAppearance.count}
      expect(page).to have_selector('#single_attachment_error', :text => "Either file or link, not both")
    end

    scenario "remove error by removing file" do
      clear_file_attachment
      expect(page).not_to have_selector('#single_attachment_error', :text => "Either file or link, not both")
    end

    scenario "remove error by deleting link" do
      delete_article_link_field
      expect(page).not_to have_selector('#single_attachment_error', :text => "Either file or link, not both")
    end
  end

  scenario "upload an unpermitted file type and cancel" do
    fill_in("media_appearance_title", :with => "My new article title")
    page.execute_script("collection.set('document_target',collection.findComponent('collectionItem'))")
    page.attach_file("primary_file", upload_image, :visible => false)
    expect(page).to have_css('#original_type_error', :text => "File type not allowed")
    expect{add_save}.not_to change{MediaAppearance.count}
    add_cancel
    expect(page).not_to have_css("#media_appearances .media_appearance")
  end

  scenario "upload a file that exceeds size limit" do
    page.execute_script("collection.set('document_target',collection.findComponent('collectionItem'))")
    page.attach_file("primary_file", big_upload_document, :visible => false)
    expect(page).to have_css('#filesize_error', :text => "File is too large")
    add_cancel
    expect(page).not_to have_css("#media_appearances .media_appearance")
  end
end

feature "when there are existing articles", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaIssuesCommonHelpers
  include MediaSpecHelper
  include MediaSetupHelper

  before do
    setup_file_constraints
  end

  feature "and existing article has file attachment" do
    before do
      setup_database(:media_appearance_with_file)
      setup_file_constraints
      resize_browser_window
      visit media_appearances_path(:en)
    end

    scenario "delete an article" do
      saved_file_path = File.join('tmp','uploads','store',MediaAppearance.first.file.id)
      expect(File.exists?(saved_file_path)).to eq true
      expect{ click_delete_article; confirm_deletion; wait_for_ajax }.to change{MediaAppearance.count}.from(1).to(0)
      expect(media_appearances.length).to eq 0
      expect(File.exists?(saved_file_path)).to eq false
    end

    scenario "edit an article without introducing errors" do
      edit_article[0].click
      fill_in("media_appearance_title", :with => "My new article title")
      expect(chars_remaining).to eq "You have 80 characters left"
      uncheck("Human Rights")
      check("media_appearance_subarea_ids_1")
      expect(page).to have_selector("input#people_affected", :visible => true)
      check("Good Governance")
      check("CRC")
      fill_in('people_affected', :with => " 100000 ")
      select('3: Has no bearing on the office', :from => 'Positivity rating')
      select('4: Serious', :from => 'Violation severity')
      expect{page.execute_script("scrollTo(0,0)"); edit_save}.to change{MediaAppearance.first.title}
      expect(MediaAppearance.first.area_ids).to eql [2]
      sleep(0.4)
      expect(page.all("#media_appearances .media_appearance .basic_info .title").first.text).to eq "My new article title"
      expect(areas).not_to include "Human Rights"
      expect(areas).to include "Good Governance"
    end

    scenario "edit an article and upload a different file" do
      edit_article[0].click
      expect(page.find('#selected_file_container').text).not_to be_blank
      previous_file_id = page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('file_id')")
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq true
      page.execute_script("collection.set('document_target',collection.findComponent('collectionItem'))")
      page.attach_file("primary_file", upload_document, :visible => false)
      edit_save
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq false
      new_file_id = page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('file_id')")
      expect(File.exists?(File.join('tmp','uploads','store',new_file_id))).to eq true
    end

    scenario "edit a file article and change to link" do
      edit_article[0].click
      previous_file_id = page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('file_id')")
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq true
      clear_file_attachment
      fill_in('media_appearance_article_link', :with => "http://www.example.com")
      edit_save
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq false
      expect(MediaAppearance.first.article_link).to eq "http://www.example.com"
      expect(MediaAppearance.first.original_filename).to be_nil
      expect(MediaAppearance.first.filesize).to be_nil
      expect(MediaAppearance.first.original_type).to be_nil
    end

    scenario "edit an article and add title error" do
      edit_article[0].click
      fill_in("media_appearance_title", :with => "")
      expect(chars_remaining).to eq "You have 100 characters left"
      expect{edit_save}.not_to change{MediaAppearance.count}
      expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
      fill_in("media_appearance_title", :with => "m")
      expect(page).not_to have_selector("#title_error", :visible => true)
    end

    scenario "edit an article and add file error" do
      edit_article[0].click
      page.execute_script("collection.set('document_target',collection.findComponent('collectionItem'))")
      page.attach_file("primary_file", upload_image, :visible => false)
      expect(page).to have_css('#original_type_error', :text => "File type not allowed")
      clear_file_attachment
      expect(page).to have_selector('#attachment_error', :text => "A file or link must be included")
      edit_cancel
      edit_article[0].click
      expect(page).not_to have_selector('#attachment_error', :text => "A file or link must be included")
    end

    scenario "edit an article, add errors, and cancel" do
      edit_article[0].click
      fill_in("media_appearance_title", :with => "")
      expect(chars_remaining).to eq "You have 100 characters left"
      expect{edit_save}.not_to change{MediaAppearance.count}
      expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
      edit_cancel
      sleep(0.2)
      edit_article[0].click
      expect(page).not_to have_selector("#title_error", :visible => true)
    end

    scenario "edit an article and cancel without saving" do
      original_media_appearance = MediaAppearance.first
      edit_article[0].click
      fill_in("media_appearance_title", :with => "My new article title")
      expect(chars_remaining).to eq "You have 80 characters left"
      uncheck("Human Rights")
      check("media_appearance_subarea_ids_1")
      expect(page).to have_selector("input#people_affected", :visible => true)
      check("Good Governance")
      check("CRC")
      fill_in('people_affected', :with => " 100000 ")
      select('3: Has no bearing on the office', :from => 'Positivity rating')
      select('4: Serious', :from => 'Violation severity')
      expect{page.execute_script("scrollTo(0,0)"); edit_cancel}.not_to change{MediaAppearance.first.title}
      expect(page.all("#media_appearances .media_appearance .basic_info .title").first.text).to eq original_media_appearance.title
      sleep(0.3) # seems to be required for test passing in chrome
      expand_all_panels
      expect(areas).to include "Human Rights"
      expect(areas).not_to include "Good Governance"
    end

    scenario "title is blank, error propagates" do # b/c there was a bug!
      add_article_button.click
      sleep(0.8)
      expect(page).to have_selector('label', :text => 'Enter web link') # to control timing
      expect{add_save}.not_to change{MediaAppearance.count}
      expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
      add_cancel
      edit_article[0].click
      expect(page).not_to have_selector("#title_error", :visible => true)
    end
  end

  feature "and existing article has link attachment" do
    before do
      setup_database(:media_appearance_with_link)
      visit media_appearances_path(:en) # again, b/c setup changed
    end

    scenario "edit a link article and change to file" do
      edit_article[0].click
      page.execute_script("collection.set('document_target',collection.findComponent('collectionItem'))")
      page.attach_file("primary_file", upload_document, :visible => false)
      fill_in('media_appearance_article_link', :with => "")
      edit_save
      expect(MediaAppearance.first.article_link).to be_blank
      expect(MediaAppearance.first.original_filename).to eq "first_upload_file.pdf"
      expect(MediaAppearance.first.filesize).to be > 0
      expect(MediaAppearance.first.original_type).to eq "application/pdf"
    end
  end

  feature "panel expansion and editing" do
    before do
      setup_database(:media_appearance_with_link)
      visit media_appearances_path(:en) # again, b/c setup changed
    end

    it "panel expanding should behave" do
      edit_article[0].click
      edit_save
      expect(page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('expanded')")).to eq true
      expect(page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('editing')")).to eq false
      edit_article[0].click
      expect(page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('expanded')")).to eq true
      expect(page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('editing')")).to eq true
      edit_cancel
      expect(page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('expanded')")).to eq false
      expect(page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('editing')")).to eq false
    end
  end
end

feature "enforce single user add or edit action", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaIssuesCommonHelpers
  include MediaSpecHelper
  include MediaSetupHelper

  before do
    setup_database(:media_appearance_with_file)
    setup_file_constraints
    add_a_second_article
    resize_browser_window
    visit media_appearances_path(:en)
  end

  scenario "user tries to edit two articles" do
    edit_article[0].click
    expect(page).to have_selector('.title .edit.in', :count => 1)
    edit_article[0].click # not the same one as before, it isn't visible any more, this is another one
    expect(page).to have_selector('.title .edit.in', :count => 1)
  end

  scenario "user tries to edit while adding" do
    add_article_button.click
    expect(page).to have_selector('.row.media_appearance.well.well-sm.form.template-upload')
    edit_article[0].click
    expect(page).to have_selector('.title .edit.in', :count => 1)
    expect(page).not_to have_selector('.row.media_appearance.well.well-sm.form.template-upload')
  end

  scenario "user tries to add while editing" do
    edit_article[0].click
    expect(page).to have_selector('.title .edit.in', :count => 1)
    add_article_button.click
    expect(page).not_to have_selector('.title .edit.in', :count => 1)
    expect(page).to have_selector('.row.media_appearance.well.well-sm.form.template-upload')
  end
end

feature "view attachments", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaIssuesCommonHelpers
  include MediaSpecHelper
  include MediaSetupHelper

  before do
    setup_file_constraints
  end

  scenario "download attached file" do
    unless page.driver.instance_of?(Capybara::Selenium::Driver) # response_headers not supported, can't test download
      setup_database(:media_appearance_with_file)
      @doc = MediaAppearance.first
      visit media_appearances_path(:en)
      click_the_download_icon
      expect(page.response_headers['Content-Type']).to eq('application/pdf')
      filename = @doc.original_filename
      expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"")
    else
      expect(1).to eq 1 # download not supported by selenium driver
    end
  end

  scenario "visit link" do
    if page.driver.is_a?(Capybara::Poltergeist::Driver)
      # b/c triggering a reload of another page triggers a phantomjs bug/error
      expect(1).to eq 1
    else
      setup_database(:media_appearance_with_link)
      visit media_appearances_path(:en)
      click_the_link_icon
      sleep(0.5)
      page.switch_to_window(page.windows[1])
      sleep(0.2)
      expect( page.evaluate_script('window.location.href')).to include first_article_link
    end
  end
end

feature "performance indicator association", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaIssuesCommonHelpers
  include MediaSpecHelper
  include MediaSetupHelper

  before do
    setup_database(:media_appearance_with_file)
    setup_strategic_plan
    setup_file_constraints
    resize_browser_window
    visit media_appearances_path(:en)
    sleep(0.4)
  end

  scenario "add a performance indicator link" do
    edit_article[0].click
    select_performance_indicators.click
    select_first_planned_result
    select_first_outcome
    select_first_activity
    select_first_performance_indicator
    pi = PerformanceIndicator.first
    expect(page).to have_selector("#performance_indicators .selected_performance_indicator", :text => pi.indexed_description )
    page.execute_script("scrollTo(0,0)")
    expect{edit_save}.to change{MediaAppearance.first.performance_indicator_ids}.from([]).to([pi.id])
  end
end

