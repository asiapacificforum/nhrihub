require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require 'download_helpers'
require_relative '../../../helpers/advisory_council/advisory_council_issues_spec_helper'
require_relative '../../../helpers/advisory_council/advisory_council_issues_setup_helper'
require 'media_issues_common_helpers'


feature "show advisory council issue archive", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaIssuesCommonHelpers
  include AdvisoryCouncilIssueSpecHelper
  include AdvisoryCouncilIssueSetupHelper

  before do
    setup_areas
    2.times do
      @issue = FactoryGirl.create(:advisory_council_issue,
                         :hr_area,
                         :reminders=>[FactoryGirl.create(:reminder, :advisory_council_issue)] )
    end
    visit nhri_advisory_council_issues_path(:en)
  end

  scenario "lists advisory council issues" do
    expect(page_heading).to eq "Advisory Council Issues"
    expect(number_of_rendered_issues).to eq 2
  end

  scenario "prepopulates title filter when title is passed as url query" do
    expect(number_of_rendered_issues).to eq 2
    url = URI(@issue.index_url)
    visit @issue.index_url.gsub(%r{.*#{url.host}},'') # hack, don't know how else to do it, host otherwise is SITE_URL defined in lib/constants
    expect(number_of_rendered_issues).to eq 1
    clear_filter_fields
    expect(number_of_rendered_issues).to eq 2
    expect(query_string).to be_blank
    click_back_button
    escaped_title_string = @issue.title.gsub(/\s/,'+')
    expect(query_string).to eq "?selection=#{escaped_title_string}"
    expect(number_of_rendered_issues).to eq 1
  end
end

feature "create a new article", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaIssuesCommonHelpers
  include AdvisoryCouncilIssueSpecHelper
  include AdvisoryCouncilIssueSetupHelper

  before do
    setup_areas
    setup_file_constraints
    visit nhri_advisory_council_issues_path(:en)
    add_article_button.click
  end

  scenario "without errors" do
    fill_in("advisory_council_issue_title", :with => "My new article title")
    expect(chars_remaining).to eq "You have 80 characters left"
    check("Human Rights")
    check("advisory_council_issue_subarea_ids_1")
    check("Good Governance")
    check("CRC")
    fill_in('advisory_council_issue_article_link', :with => "http://www.example.com")
    expect{add_save}.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}.from(0).to(1)
    expect(page).to have_selector("#advisory_council_issues .advisory_council_issue", :count => 1)
    expect(page.find("#advisory_council_issues .advisory_council_issue .basic_info .title").text).to eq "My new article title"
    expand_all_panels
    expect(areas).to include "Human Rights"
    expect(areas).to include "Good Governance"
    expect(subareas).to include "CRC"
  end

  scenario "upload article from file" do
    fill_in("advisory_council_issue_title", :with => "My new article title")
    page.execute_script("collection.set('document_target',collection.findComponent('collectionItem'))")
    page.attach_file("primary_file", upload_document, :visible => false)
    expect{add_save}.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}.from(0).to(1)
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
    expect{add_save}.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}.from(0).to(1)
    expect(page).to have_selector("#advisory_council_issues .advisory_council_issue", :count => 1)
    expect(page.all("#advisory_council_issues .advisory_council_issue .basic_info .title").first.text).to eq "My new article title"
    add_article_button.click
    fill_in("advisory_council_issue_title", :with => "My second new article title")
    fill_in('advisory_council_issue_article_link', :with => "http://www.example.com")
    expect{add_save}.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}.from(1).to(2)
    expect(page).to have_selector("#advisory_council_issues .advisory_council_issue", :count => 2)
    expect(page.all("#advisory_council_issues .advisory_council_issue .basic_info .title")[0].text).to eq "My second new article title"
    expect(page.all("#advisory_council_issues .advisory_council_issue .basic_info .title")[1].text).to eq "My new article title"
  end

  scenario "start creating and cancel" do
    add_cancel
    expect(page).not_to have_selector('.form #advisory_council_issue_title')
  end
end

feature "attempt to add and save with errors", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaIssuesCommonHelpers
  include AdvisoryCouncilIssueSpecHelper
  include AdvisoryCouncilIssueSetupHelper

  before do
    setup_areas
    setup_file_constraints
    visit nhri_advisory_council_issues_path(:en)
    add_article_button.click
  end

  scenario "title is blank" do
    expect(page).to have_selector('label', :text => 'Enter web link') # to control timing
    expect{add_save}.not_to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in("advisory_council_issue_title", :with => "m")
    expect(page).not_to have_selector("#title_error", :visible => true)
  end

  feature "neither link nor file is included" do
    before do
      fill_in("advisory_council_issue_title", :with => "My new article title")
      # unlike media_appearance, advisory_council_issue may not have a link or file
      expect{add_save}.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}.by(1)
      expect(page).not_to have_selector('#attachment_error', :text => "A file or link must be included")
    end
  end

  feature "both link and file are included" do
    before do
      fill_in("advisory_council_issue_title", :with => "My new article title")
      page.execute_script("collection.set('document_target',collection.findComponent('collectionItem'))")
      page.attach_file("primary_file", upload_document, :visible => false)
      fill_in("advisory_council_issue_article_link", :with => "h")
      expect{add_save}.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}.by(1)
      expect(page).not_to have_selector('#single_attachment_error')
    end

    #scenario "remove error by removing file" do
      #clear_file_attachment
      #expect(page).not_to have_selector('#single_attachment_error', :text => "Either file or link, not both")
    #end

    #scenario "remove error by deleting link" do
      #delete_article_link_field
      #expect(page).not_to have_selector('#single_attachment_error', :text => "Either file or link, not both")
    #end
  end

  scenario "upload an unpermitted file type and cancel" do
    fill_in("advisory_council_issue_title", :with => "My new article title")
    page.execute_script("collection.set('document_target',collection.findComponent('collectionItem'))")
    page.attach_file("primary_file", upload_image, :visible => false)
    expect(page).to have_css('#original_type_error', :text => "File type not allowed")
    expect{add_save}.not_to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}
    add_cancel
    expect(page).not_to have_css("#advisory_council_issues .advisory_council_issue")
  end

  scenario "upload a file that exceeds size limit" do
    page.execute_script("collection.set('document_target',collection.findComponent('collectionItem'))")
    page.attach_file("primary_file", big_upload_document, :visible => false)
    expect(page).to have_css('#filesize_error', :text => "File is too large")
    add_cancel
    expect(page).not_to have_css("#advisory_council_issues .advisory_council_issue")
  end
end

feature "when there are existing articles", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaIssuesCommonHelpers
  include AdvisoryCouncilIssueSpecHelper
  include AdvisoryCouncilIssueSetupHelper

  feature "and existing article has file attachment" do
    before do
      setup_database
      setup_file_constraints
      visit nhri_advisory_council_issues_path(:en)
    end

    # b/c there was a bug!
    scenario "start creating and cancel" do
      add_article_button.click
      check("Human Rights")
      check("advisory_council_issue_subarea_ids_1") # violation
      add_cancel
      expect(page).not_to have_selector('.form #advisory_council_issue_title')
      scroll_to(edit_article[0]).click
    end

    scenario "delete an article" do
      saved_file_path = File.join('tmp','uploads','store',Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.file.id)
      expect(File.exists?(saved_file_path)).to eq true
      expect{ click_delete_article; confirm_deletion; wait_for_ajax }.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}.from(1).to(0)
      expect(advisory_council_issues.length).to eq 0
      expect(File.exists?(saved_file_path)).to eq false
    end

    scenario "edit an article without introducing errors" do
      scroll_to(edit_article[0]).click
      fill_in("advisory_council_issue_title", :with => "My new article title")
      expect(chars_remaining).to eq "You have 80 characters left"
      uncheck("Human Rights")
      check("advisory_council_issue_subarea_ids_1")
      check("Good Governance")
      check("CRC")
      expect{edit_save}.to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.title}
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.area_ids).to eql [2]
      expect(page.all("#advisory_council_issues .advisory_council_issue .basic_info .title").first.text).to eq "My new article title"
      expect(areas).not_to include "Human Rights"
      expect(areas).to include "Good Governance"
    end

    scenario "edit an article and upload a different file" do
      scroll_to(edit_article[0]).click
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
      scroll_to(edit_article[0]).click
      previous_file_id = page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('file_id')")
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq true
      clear_file_attachment
      fill_in('advisory_council_issue_article_link', :with => "http://www.example.com")
      edit_save
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq false
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.article_link).to eq "http://www.example.com"
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.original_filename).to be_nil
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.filesize).to be_nil
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.original_type).to be_nil
    end

    scenario "edit a file article and add a link" do
      scroll_to(edit_article[0]).click
      previous_file_id = page.evaluate_script("collection.findAllComponents('collectionItem')[0].get('file_id')")
      previous_file = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq true
      fill_in('advisory_council_issue_article_link', :with => "http://www.example.com")
      expect(page).not_to have_selector('#single_attachment_error', :text => 'Either file or link, not both')
      expect{edit_save}.not_to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}
      expect(File.exists?(File.join('tmp','uploads','store',previous_file_id))).to eq true
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.article_link).to eq "http://www.example.com"
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.original_filename).to eq previous_file.original_filename
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.filesize).to eq previous_file.filesize
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.original_type).to eq previous_file.original_type
    end

    scenario "edit an article and add title error" do
      scroll_to(edit_article[0]).click
      fill_in("advisory_council_issue_title", :with => "")
      expect(chars_remaining).to eq "You have 100 characters left"
      expect{edit_save}.not_to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}
      expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
      fill_in("advisory_council_issue_title", :with => "m")
      expect(page).not_to have_selector("#title_error", :visible => true)
    end

    scenario "edit an article and add file error" do
      scroll_to(edit_article[0]).click
      page.execute_script("collection.set('document_target',collection.findComponent('collectionItem'))")
      page.attach_file("primary_file", upload_image, :visible => false)
      expect(page).to have_css('#original_type_error', :text => "File type not allowed")
      clear_file_attachment
      expect(page).not_to have_selector('#attachment_error', :text => "A file or link must be included")
      edit_cancel
      scroll_to(edit_article[0]).click
      expect(page).not_to have_selector('#attachment_error', :text => "A file or link must be included")
    end

    scenario "edit an article, add errors, and cancel" do
      scroll_to(edit_article[0]).click
      fill_in("advisory_council_issue_title", :with => "")
      expect(chars_remaining).to eq "You have 100 characters left"
      expect{edit_save}.not_to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}
      expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
      edit_cancel
      scroll_to(edit_article[0]).click
      expect(page).not_to have_selector("#title_error", :visible => true)
    end

    scenario "edit an article and cancel without saving" do
      original_advisory_council_issue = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first
      scroll_to(edit_article[0]).click
      fill_in("advisory_council_issue_title", :with => "My new article title")
      expect(chars_remaining).to eq "You have 80 characters left"
      uncheck("Human Rights")
      check("advisory_council_issue_subarea_ids_1")
      check("Good Governance")
      check("CRC")
      expect{edit_cancel}.not_to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.title}
      expect(page.all("#advisory_council_issues .advisory_council_issue .basic_info .title").first.text).to eq original_advisory_council_issue.title
      sleep(0.3) # seems to be required for proper operation in chrome
      expand_all_panels
      expect(areas).to include "Human Rights"
      expect(areas).not_to include "Good Governance"
    end

    scenario "title is blank, error should not propagate" do # b/c there was a bug!
      add_article_button.click
      expect(page).to have_selector('label', :text => 'Enter web link') # to control timing
      expect{add_save}.not_to change{Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.count}
      expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
      add_cancel
      scroll_to(edit_article[0]).click
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
      scroll_to(edit_article[0]).click
      page.execute_script("collection.set('document_target',collection.findComponent('collectionItem'))")
      page.attach_file("primary_file", upload_document, :visible => false)
      edit_save
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.article_link).not_to be_blank
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.original_filename).to eq "first_upload_file.pdf"
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.filesize).to be > 0
      expect(Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first.original_type).to eq "application/pdf"
    end
  end
end

feature "enforce single user add or edit action", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaIssuesCommonHelpers
  include AdvisoryCouncilIssueSpecHelper
  include AdvisoryCouncilIssueSetupHelper

  before do
    setup_database
    add_a_second_article
    visit nhri_advisory_council_issues_path(:en)
  end

  scenario "user tries to edit two articles" do
    scroll_to(edit_article[0]).click
    expect(page).to have_selector('.title .edit.in', :count => 1)
    scroll_to(edit_article[0]).click # not the same one as before, it isn't visible any more, this is another one
    expect(page).to have_selector('.title .edit.in', :count => 1)
  end

  scenario "user tries to edit while adding" do
    add_article_button.click
    expect(page).to have_selector('.row.advisory_council_issue.well.well-sm.form.template-upload')
    scroll_to(edit_article[0]).click
    expect(page).to have_selector('.title .edit.in', :count => 1)
    expect(page).not_to have_selector('.row.advisory_council_issue.well.well-sm.form.template-upload')
  end

  scenario "user tries to add while editing" do
    scroll_to(edit_article[0]).click
    expect(page).to have_selector('.title .edit.in', :count => 1)
    add_article_button.click
    expect(page).not_to have_selector('.title .edit.in', :count => 1)
    expect(page).to have_selector('.row.advisory_council_issue.well.well-sm.form.template-upload')
  end
end

feature "view attachments", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaIssuesCommonHelpers
  include AdvisoryCouncilIssueSpecHelper
  include AdvisoryCouncilIssueSetupHelper
  include DownloadHelpers

  scenario "download attached file", :driver => :chrome do
    setup_database
    doc = Nhri::AdvisoryCouncil::AdvisoryCouncilIssue.first
    visit nhri_advisory_council_issues_path(:en)
    click_the_download_icon
    unless page.driver.instance_of?(Capybara::Selenium::Driver) # response_headers not supported
      expect(page.response_headers['Content-Type']).to eq('application/pdf')
      filename = doc.original_filename
      expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"")
    end
    expect(downloaded_file).to eq doc.original_filename
  end

  scenario "visit link" do
    if page.driver.is_a?(Capybara::Poltergeist::Driver)
      # b/c triggering a reload of another page triggers a phantomjs bug/error
      expect(1).to eq 1
    else
      setup_database(:advisory_council_issue_with_link)
      visit nhri_advisory_council_issues_path(:en)
      click_the_link_icon
      page.switch_to_window(page.windows[-1])
      page.find('h1',:text => "Example Domain") # better than sleep to await the page load
      expect( page.evaluate_script('window.location.href')).to include first_article_link
    end
  end
end
