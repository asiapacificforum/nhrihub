require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../../helpers/advisory_council/advisory_council_issues_spec_helper'
require_relative '../../../helpers/advisory_council/advisory_council_issues_setup_helper'


feature "show advisory council issue archive", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include AdvisoryCouncilIssueSpecHelper
  include AdvisoryCouncilIssueSetupHelper

  before do
    setup_areas
    FactoryGirl.create(:advisory_council_issue,
                       :hr_area,
                       :reminders=>[FactoryGirl.create(:reminder, :advisory_council_issue)] )
    resize_browser_window
    visit nhri_advisory_council_issues_path(:en)
  end

  scenario "lists advisory council issues" do
    expect(page_heading).to eq "Advisory Council Issues"
    expect(page).to have_selector("#advisory_council_issues .advisory_council_issue", :count => 1)
  end
end

feature "create a new article", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include AdvisoryCouncilIssueSpecHelper
  include AdvisoryCouncilIssueSetupHelper

  before do
    setup_areas
    setup_violation_severities
    setup_file_constraints
    resize_browser_window
    visit nhri_advisory_council_issues_path(:en)
    add_article_button.click
  end

  scenario "without errors" do
    fill_in("advisory_council_issue_title", :with => "My new article title")
    expect(chars_remaining).to eq "You have 80 characters left"
    expect(page).not_to have_selector("input#people_affected", :visible => true)
    #expect(page.find('#advisory_council_issue_subarea_ids_1')).to be_disabled # defer until ractive 0.8.0 is stable
    #expect(page.find('#advisory_council_issue_subarea_ids_2')).to be_disabled
    #expect(page.find('#advisory_council_issue_subarea_ids_3')).to be_disabled
    #expect(page.find('#advisory_council_issue_subarea_ids_4')).to be_disabled
    #expect(page.find('#advisory_council_issue_subarea_ids_5')).to be_disabled
    check("Human Rights")
    check("advisory_council_issue_subarea_ids_1")
    expect(page).to have_selector("input#people_affected", :visible => true)
    check("Good Governance")
    check("CRC")
    fill_in('people_affected', :with => " 100000 ")
    select('4: Serious', :from => 'Violation severity')
    fill_in('advisory_council_issue_article_link', :with => "http://www.example.com")
    expect{page.execute_script("scrollTo(0,0)"); edit_save.click; sleep(0.5)}.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}.from(0).to(1)
    ma = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first
    expect(ma.affected_people_count).to eq 100000 # b/c this attribute now returns a hash!
    sleep(0.4)
    expect(page).to have_selector("#advisory_council_issues .advisory_council_issue", :count => 1)
    expect(page.find("#advisory_council_issues .advisory_council_issue .basic_info .title").text).to eq "My new article title"
    expand_all_panels
    expect(areas).to include "Human Rights"
    expect(areas).to include "Good Governance"
    expect(subareas).to include "CRC"
    expect(violation_severity).to eq "4: Serious"
    expect(people_affected.gsub(/,/,'')).to eq "100000" # b/c phantomjs does not have a toLocaleString() method
  end

  scenario "upload article from file" do
    fill_in("advisory_council_issue_title", :with => "My new article title")
    page.attach_file("advisory_council_issue_file", upload_document, :visible => false)
    expect{edit_save.click; sleep(0.4)}.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}.from(0).to(1)
    expect(page).to have_css("#advisory_council_issues .advisory_council_issue", :count => 1)
    doc = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.last
    expect( doc.title ).to eq "My new article title"
    expect( doc.filesize ).to be > 0 # it's the best we can do, if we don't know the file size
    expect( doc.original_filename ).to eq 'first_upload_file.pdf'
    expect( doc.lastModifiedDate ).to be_a ActiveSupport::TimeWithZone # it's a weak assertion!
    expect( doc.original_type ).to eq "application/pdf"
  end

  scenario "repeated adds" do # b/c there was a bug!
    fill_in("advisory_council_issue_title", :with => "My new article title")
    expect(chars_remaining).to eq "You have 80 characters left"
    fill_in('advisory_council_issue_article_link', :with => "http://www.example.com")
    expect{edit_save.click; sleep(0.4)}.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}.from(0).to(1)
    sleep(0.4)
    expect(page).to have_selector("#advisory_council_issues .advisory_council_issue", :count => 1)
    expect(page.all("#advisory_council_issues .advisory_council_issue .basic_info .title").first.text).to eq "My new article title"
    add_article_button.click
    fill_in("advisory_council_issue_title", :with => "My second new article title")
    fill_in('advisory_council_issue_article_link', :with => "http://www.example.com")
    expect{edit_save.click; sleep(0.4)}.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}.from(1).to(2)
    sleep(0.4)
    expect(page).to have_selector("#advisory_council_issues .advisory_council_issue", :count => 2)
    expect(page.all("#advisory_council_issues .advisory_council_issue .basic_info .title")[0].text).to eq "My second new article title"
    expect(page.all("#advisory_council_issues .advisory_council_issue .basic_info .title")[1].text).to eq "My new article title"
  end

  scenario "start creating and cancel" do
    cancel_article_add
    expect(page).not_to have_selector('.form #advisory_council_issue_title')
  end
end

feature "attempt to save with errors", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include AdvisoryCouncilIssueSpecHelper
  include AdvisoryCouncilIssueSetupHelper

  before do
    setup_areas
    setup_violation_severities
    setup_file_constraints
    resize_browser_window
    visit nhri_advisory_council_issues_path(:en)
    add_article_button.click
  end

  scenario "title is blank" do
    sleep(0.8)
    expect(page).to have_selector('label', :text => 'Enter web link') # to control timing
    expect{edit_save.click; sleep(0.4)}.not_to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in("advisory_council_issue_title", :with => "m")
    expect(page).not_to have_selector("#title_error", :visible => true)
  end

  feature "neither link nor file is included" do
    before do
      fill_in("advisory_council_issue_title", :with => "My new article title")
      # unlike media_appearance, advisory_council_issue may not have a link or file
      expect{edit_save.click; sleep(0.4)}.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}.by(1)
      expect(page).not_to have_selector('#collection_item_error', :text => "A file or link must be included")
    end
  end

  feature "both link and file are included" do
    before do
      fill_in("advisory_council_issue_title", :with => "My new article title")
      page.attach_file("advisory_council_issue_file", upload_document, :visible => false)
      fill_in("advisory_council_issue_article_link", :with => "h")
      expect{edit_save.click; sleep(0.4)}.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}.by(1)
      expect(page).not_to have_selector('#collection_item_attachment_error')
    end

    #scenario "remove error by removing file" do
      #clear_file_attachment
      #expect(page).not_to have_selector('#collection_item_attachment_error', :text => "Either file or link, not both")
    #end

    #scenario "remove error by deleting link" do
      #delete_article_link_field
      #expect(page).not_to have_selector('#collection_item_attachment_error', :text => "Either file or link, not both")
    #end
  end

  scenario "upload an unpermitted file type and cancel" do
    fill_in("advisory_council_issue_title", :with => "My new article title")
    page.attach_file("advisory_council_issue_file", upload_image, :visible => false)
    expect(page).to have_css('#filetype_error', :text => "File type not allowed")
    expect{edit_save.click; sleep(0.5)}.not_to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}
    page.find(".advisory_council_issue i#edit_cancel").click
    expect(page).not_to have_css("#advisory_council_issues .advisory_council_issue")
  end

  scenario "upload a file that exceeds size limit" do
    page.attach_file("advisory_council_issue_file", big_upload_document, :visible => false)
    expect(page).to have_css('#filesize_error', :text => "File is too large")
    page.find(".advisory_council_issue i#edit_cancel").click
    expect(page).not_to have_css("#advisory_council_issues .advisory_council_issue")
  end
end

feature "when there are existing articles", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include AdvisoryCouncilIssueSpecHelper
  include AdvisoryCouncilIssueSetupHelper

  feature "and existing article has file attachment" do
    before do
      setup_database
      setup_file_constraints
      resize_browser_window
      visit nhri_advisory_council_issues_path(:en)
    end

    scenario "delete an article" do
      saved_file_path = File.join('tmp','uploads','store',Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.file.id)
      expect(File.exists?(saved_file_path)).to eq true
      expect{ delete_article }.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}.from(1).to(0)
      expect(advisory_council_issues.length).to eq 0
      expect(File.exists?(saved_file_path)).to eq false
    end

    scenario "edit an article without introducing errors" do
      edit_article[0].click
      fill_in("advisory_council_issue_title", :with => "My new article title")
      expect(chars_remaining).to eq "You have 80 characters left"
      uncheck("Human Rights")
      check("advisory_council_issue_subarea_ids_1")
      expect(page).to have_selector("input#people_affected", :visible => true)
      check("Good Governance")
      check("CRC")
      fill_in('people_affected', :with => " 100000 ")
      select('4: Serious', :from => 'Violation severity')
      expect{page.execute_script("scrollTo(0,0)"); edit_save.click; sleep(0.4)}.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.title}
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.area_ids).to eql [2]
      sleep(0.4)
      expect(page.all("#advisory_council_issues .advisory_council_issue .basic_info .title").first.text).to eq "My new article title"
      expect(areas).not_to include "Human Rights"
      expect(areas).to include "Good Governance"
    end

    scenario "edit an article and upload a different file" do
      edit_article[0].click
      expect(page.find('#selected_file_container').text).not_to be_blank
      previous_file_id = page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('file_id')")
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq true
      page.attach_file("advisory_council_issue_file", upload_document, :visible => false)
      edit_save.click
      sleep(0.4)
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq false
      new_file_id = page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('file_id')")
      expect(File.exists?(File.join('tmp','uploads','store',new_file_id))).to eq true
    end

    scenario "edit a file article and change to link" do
      edit_article[0].click
      previous_file_id = page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('file_id')")
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq true
      clear_file_attachment
      fill_in('advisory_council_issue_article_link', :with => "http://www.example.com")
      edit_save.click
      sleep(0.4)
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq false
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.article_link).to eq "http://www.example.com"
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.original_filename).to be_nil
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.filesize).to be_nil
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.original_type).to be_nil
    end

    scenario "edit a file article and add a link" do
      edit_article[0].click
      previous_file_id = page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('file_id')")
      previous_file = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq true
      fill_in('advisory_council_issue_article_link', :with => "http://www.example.com")
      sleep(0.2)
      expect(page).not_to have_selector('#collection_item_attachment_error', :text => 'Either file or link, not both')
      expect{edit_save.click; sleep(0.4) }.not_to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq true
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.article_link).to eq "http://www.example.com"
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.original_filename).to eq previous_file.original_filename
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.filesize).to eq previous_file.filesize
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.original_type).to eq previous_file.original_type
    end

    scenario "edit an article and add title error" do
      edit_article[0].click
      fill_in("advisory_council_issue_title", :with => "")
      expect(chars_remaining).to eq "You have 100 characters left"
      expect{edit_save.click; sleep(0.4)}.not_to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}
      expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
      fill_in("advisory_council_issue_title", :with => "m")
      expect(page).not_to have_selector("#title_error", :visible => true)
    end

    scenario "edit an article and add file error" do
      edit_article[0].click
      page.attach_file("advisory_council_issue_file", upload_image, :visible => false)
      expect(page).to have_css('#filetype_error', :text => "File type not allowed")
      clear_file_attachment
      expect(page).not_to have_selector('#collection_item_error', :text => "A file or link must be included")
      edit_cancel.click
      sleep(0.2)
      edit_article[0].click
      expect(page).not_to have_selector('#collection_item_error', :text => "A file or link must be included")
    end

    scenario "edit an article, add errors, and cancel" do
      edit_article[0].click
      fill_in("advisory_council_issue_title", :with => "")
      expect(chars_remaining).to eq "You have 100 characters left"
      expect{edit_save.click; sleep(0.4)}.not_to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}
      expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
      edit_cancel.click
      sleep(0.2)
      edit_article[0].click
      expect(page).not_to have_selector("#title_error", :visible => true)
    end

    scenario "edit an article and cancel without saving" do
      original_advisory_council_issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first
      edit_article[0].click
      fill_in("advisory_council_issue_title", :with => "My new article title")
      expect(chars_remaining).to eq "You have 80 characters left"
      uncheck("Human Rights")
      check("advisory_council_issue_subarea_ids_1")
      expect(page).to have_selector("input#people_affected", :visible => true)
      check("Good Governance")
      check("CRC")
      fill_in('people_affected', :with => " 100000 ")
      select('4: Serious', :from => 'Violation severity')
      expect{page.execute_script("scrollTo(0,0)"); edit_cancel.click; sleep(0.4)}.not_to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.title}
      expect(page.all("#advisory_council_issues .advisory_council_issue .basic_info .title").first.text).to eq original_advisory_council_issue.title
      expand_all_panels
      expect(areas).to include "Human Rights"
      expect(areas).not_to include "Good Governance"
    end

    scenario "title is blank, error should not propagate" do # b/c there was a bug!
      add_article_button.click
      sleep(0.8)
      expect(page).to have_selector('label', :text => 'Enter web link') # to control timing
      expect{edit_save.click; sleep(0.4)}.not_to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}
      expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
      page.find(".advisory_council_issue i#edit_cancel").click
      edit_article[0].click
      expect(page).not_to have_selector("#title_error", :visible => true)
    end
  end

  feature "and existing article has link attachment" do
    before do
      setup_database(:advisory_council_issue_with_link)
      setup_file_constraints
      visit  nhri_advisory_council_issues_path(:en) # again, b/c setup changed
    end

    scenario "edit a link article and add a file" do
      edit_article[0].click
      page.attach_file("advisory_council_issue_file", upload_document, :visible => false)
      edit_save.click
      sleep(0.4)
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.article_link).not_to be_blank
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.original_filename).to eq "first_upload_file.pdf"
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.filesize).to be > 0
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.original_type).to eq "application/pdf"
    end
  end
end

feature "enforce single user add or edit action", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include AdvisoryCouncilIssueSpecHelper
  include AdvisoryCouncilIssueSetupHelper

  before do
    setup_database
    add_a_second_article
    resize_browser_window
    visit nhri_advisory_council_issues_path(:en)
  end

  scenario "user tries to edit two articles" do
    edit_article[0].click
    expect(page).to have_selector('.title .edit.in', :count => 1)
    edit_article[0].click # not the same one as before, it isn't visible any more, this is another one
    expect(page).to have_selector('.title .edit.in', :count => 1)
  end

  scenario "user tries to edit while adding" do
    add_article_button.click
    expect(page).to have_selector('.row.advisory_council_issue.well.well-sm.form.template-upload')
    edit_article[0].click
    expect(page).to have_selector('.title .edit.in', :count => 1)
    expect(page).not_to have_selector('.row.advisory_council_issue.well.well-sm.form.template-upload')
  end

  scenario "user tries to add while editing" do
    edit_article[0].click
    expect(page).to have_selector('.title .edit.in', :count => 1)
    add_article_button.click
    expect(page).not_to have_selector('.title .edit.in', :count => 1)
    expect(page).to have_selector('.row.advisory_council_issue.well.well-sm.form.template-upload')
  end
end

feature "view attachments", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include AdvisoryCouncilIssueSpecHelper
  include AdvisoryCouncilIssueSetupHelper

  scenario "download attached file" do
    unless page.driver.instance_of?(Capybara::Selenium::Driver) # response_headers not supported, can't test download
      setup_database
      @doc = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first
      visit nhri_advisory_council_issues_path(:en)
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
      setup_database(:advisory_council_issue_with_link)
      visit nhri_advisory_council_issues_path(:en)
      click_the_link_icon
      sleep(0.5)
      page.switch_to_window(page.windows[1])
      expect( page.evaluate_script('window.location.href')).to include first_article_link
    end
  end
end
