require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/media_spec_helper'
require_relative '../helpers/setup_helper'


feature "show media archive", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaSpecHelper
  include SetupHelper

  before do
    setup_positivity_ratings
    setup_areas
    FactoryGirl.create(:media_appearance, :hr_area, :positivity_rating => PositivityRating.first, :reminders=>[FactoryGirl.create(:reminder, :media_appearance)] )
    visit outreach_media_media_appearances_path(:en)
  end

  scenario "human rights description variable" do
    expect(page_heading).to eq "Media Archive"
    expect(page).to have_selector("#media_appearances .media_appearance", :count => 1)
  end
end

feature "create a new article", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaSpecHelper
  include SetupHelper

  before do
    setup_positivity_ratings
    setup_areas
    setup_violation_severities
    visit outreach_media_media_appearances_path(:en)
    add_article_button.click
  end

  scenario "without errors" do
    fill_in("media_appearance_title", :with => "My new article title")
    expect(chars_remaining).to eq "You have 80 characters left"
    expect(page).not_to have_selector("input#people_affected", :visible => true)
    #expect(page.find('#media_appearance_subarea_ids_1')).to be_disabled
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
    expect{edit_save.click; sleep(0.4)}.to change{MediaAppearance.count}.from(0).to(1)
    ma = MediaAppearance.first
    expect(ma.affected_people_count).to eq 100000
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

  scenario "repeated adds" do # b/c there was a bug!
    fill_in("media_appearance_title", :with => "My new article title")
    expect(chars_remaining).to eq "You have 80 characters left"
    expect{edit_save.click; sleep(0.4)}.to change{MediaAppearance.count}.from(0).to(1)
    sleep(0.4)
    expect(page).to have_selector("#media_appearances .media_appearance", :count => 1)
    expect(page.all("#media_appearances .media_appearance .basic_info .title").first.text).to eq "My new article title"
    add_article_button.click
    fill_in("media_appearance_title", :with => "My second new article title")
    expect{edit_save.click; sleep(0.4)}.to change{MediaAppearance.count}.from(1).to(2)
    sleep(0.4)
    expect(page).to have_selector("#media_appearances .media_appearance", :count => 2)
    expect(page.all("#media_appearances .media_appearance .basic_info .title")[0].text).to eq "My second new article title"
    expect(page.all("#media_appearances .media_appearance .basic_info .title")[1].text).to eq "My new article title"
  end

  scenario "start creating and cancel" do
    cancel_article_add
    expect(page).not_to have_selector('.form #media_appearance_title')
  end
end

feature "attempt to save with errors", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaSpecHelper
  include SetupHelper

  before do
    setup_positivity_ratings
    setup_areas
    setup_violation_severities
    visit outreach_media_media_appearances_path(:en)
    add_article_button.click
  end

  scenario "title is blank" do
    expect{edit_save.click; sleep(0.4)}.not_to change{MediaAppearance.count}
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in("media_appearance_title", :with => "m")
    expect(page).not_to have_selector("#title_error", :visible => true)
  end
end

feature "when there are existing articles", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaSpecHelper
  include SetupHelper

  before do
    setup_database
    visit outreach_media_media_appearances_path(:en)
  end

  scenario "delete an article" do
    expect{ delete_article }.to change{MediaAppearance.count}.from(1).to(0)
    expect(media_appearances.length).to eq 0
  end

  scenario "edit an article without introducing errors" do
    edit_article.click
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
    expect{edit_save.click; sleep(0.4)}.to change{MediaAppearance.first.title}
    expect(MediaAppearance.first.area_ids).to eql [2]
    sleep(0.4)
    expect(page.all("#media_appearances .media_appearance .basic_info .title").first.text).to eq "My new article title"
    expect(areas).not_to include "Human Rights"
    expect(areas).to include "Good Governance"
  end

  scenario "edit an article and add errors" do
    edit_article.click
    fill_in("media_appearance_title", :with => "")
    expect(chars_remaining).to eq "You have 100 characters left"
    expect{edit_save.click; sleep(0.4)}.not_to change{MediaAppearance.count}
    expect(page).to have_selector("#title_error", :text => "Title cannot be blank")
    fill_in("media_appearance_title", :with => "m")
    expect(page).not_to have_selector("#title_error", :visible => true)
  end

  scenario "edit an article and cancel without saving" do
    original_media_appearance = MediaAppearance.first
    edit_article.click
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
    expect{edit_cancel.click; sleep(0.4)}.not_to change{MediaAppearance.first.title}
    expect(page.all("#media_appearances .media_appearance .basic_info .title").first.text).to eq original_media_appearance.title
    expect(areas).to include "Human Rights"
    expect(areas).not_to include "Good Governance"
  end
end
