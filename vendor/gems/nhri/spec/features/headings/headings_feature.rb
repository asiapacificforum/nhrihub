require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/headings/headings_spec_helper'


feature "show icc index page", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include HeadingsSpecHelper

  before do
    visit nhri_headings_path(:en)
  end

  it "shows the indicators page" do
    expect(page).to have_selector('h1',:text => 'National Human Rights Indicators')
  end

  it "can add new headings" do
    add_heading.click
    fill_in('heading_title', :with => "Some new heading text")
    expect{save_heading.click; sleep(0.3)}.to change{Nhri::Indicator::Heading.count}.by(1)
    expect(Nhri::Indicator::Heading.first.title).to eq "Some new heading text"
    expect(page).to have_selector('#headings_container .heading', :count => 1)
    expect(page).to have_selector('#headings_container .heading .title', :text => "Some new heading text")
  end

  it "can cancel the adding of new headings and the entereed title is reset" do
    add_heading.click
    fill_in('heading_title', :with => "Some new heading text")
    cancel_add.click
    expect(page).not_to have_selector('#heading_save')
    add_heading.click
    expect(page.find('#heading_title').value).to be_blank
  end

  it "does not validate a blank or whitespace title" do
    add_heading.click
    expect(page).not_to have_selector('#title_error', :text => "Title can't be blank.")
    fill_in('heading_title', :with => "   ")
    expect{save_heading.click; sleep(0.3)}.not_to change{Nhri::Indicator::Heading.count}
    expect(page).to have_selector('#title_error', :text => "Title can't be blank.")
    expect(page).to have_selector('#heading_save')
    cancel_add.click
    expect(page).not_to have_selector('#heading_save')
    add_heading.click
    expect(page).not_to have_selector('#title_error', :text => "Title can't be blank.")
  end

  it "can add only one new heading at a time" do
    add_heading.click
    add_heading.click
    expect(page.all('#heading_save').length).to eq 1
  end
end

feature "index page behaviour with existing headings", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include HeadingsSpecHelper

  before do
    setup_database
    visit nhri_headings_path(:en)
  end

  it "can delete a heading" do
    expect{delete_heading.click; sleep(0.3)}.to change{Nhri::Indicator::Heading.count}.by(-1)
    expect(page).not_to have_selector('#headings_container .heading')
  end

  it "can edit the title of a heading" do
    edit_heading.click
    page.find('#heading_title').set("I changed my mind")
    expect{edit_save.click; sleep(0.3)}.to change{Nhri::Indicator::Heading.first.title}.to("I changed my mind")
    expect(page).to have_selector('#headings_container .heading .title', :text => "I changed my mind")
  end

  it "does not validate if heading title is edited to invalid value" do
    edit_heading.click
    page.find('#heading_title').set("  ")
    expect{edit_save.click; sleep(0.3)}.not_to change{Nhri::Indicator::Heading.first.title}
    expect(page).to have_selector('#title_error', :text => "Title can't be blank.")
  end

  it "restores previous value if editing is started and cancelled" do
    edit_heading.click
    page.find('#heading_title').set("I changed my mind")
    edit_cancel.click
    expect(page).to have_selector('#headings_container .heading .title', :text => "My really cool heading")
  end
end
