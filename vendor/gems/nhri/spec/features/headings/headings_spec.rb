require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/headings/headings_spec_helper'


feature "show headings index page", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include HeadingsSpecHelper

  before do
    visit nhri_headings_path(:en)
  end

  it "shows the indicators page" do
    expect(page).to have_selector('h1',:text => 'Human Rights Indicators: Headings')
  end

  it "can add new headings" do
    add_heading.click
    fill_in('heading_title', :with => "Some new heading text")
    add_offence.click
    page.find('.offence_description').set('Offence text')
    add_offence.click
    page.all('.offence_description')[0].set('Second offence text')
    expect{save_heading.click; sleep(0.3)}.to change{Nhri::Heading.count}.by(1).
                                           and change{Nhri::Offence.count}.by(2)
    expect(Nhri::Heading.first.offences.count).to eq 2
    expect(Nhri::Heading.first.title).to eq "Some new heading text"
    expect(Nhri::Heading.first.offences.map(&:description)).to include "Offence text"
    expect(Nhri::Heading.first.offences.map(&:description)).to include "Second offence text"
    expect(page).to have_selector('#headings_container .heading', :count => 1)
    expect(page).to have_selector('#headings_container .heading .title', :text => "Some new heading text")
  end

  it "can add new headings with no offences" do
    add_heading.click
    fill_in('heading_title', :with => "Some new heading text")
    expect{save_heading.click; sleep(0.3)}.to change{Nhri::Heading.count}.by(1)
    expect(Nhri::Heading.first.title).to eq "Some new heading text"
    expect(page).to have_selector('#headings_container .heading', :count => 1)
    expect(page).to have_selector('#headings_container .heading .title', :text => "Some new heading text")
  end

  it "removes title error when heading title is typed" do
    add_heading.click
    fill_in('heading_title', :with => "   ")
    save_heading.click
    expect(page).to have_selector('#title_error', :text => "Title can't be blank.")
    fill_in('heading_title', :with => "Bish bash bosh")
    expect(page).not_to have_selector('#title_error', :text => "Title can't be blank.")
  end

  it "can delete new heading when it has been added" do
    add_heading.click
    fill_in('heading_title', :with => "Some new heading text")
    expect{save_heading.click; sleep(0.3)}.to change{Nhri::Heading.count}.by(1)
    expect(page).to have_selector('#headings_container .heading .title', :text => "Some new heading text")
    expect{delete_heading.click; sleep(0.3)}.to change{Nhri::Heading.count}.by(-1).
                                             and change{page.all('#headings_container .heading').count}.by(-1)
  end

  it "does not persist empty offences" do
    add_heading.click
    fill_in('heading_title', :with => "Some new heading text")
    add_offence.click
    expect{save_heading.click; sleep(0.3)}.to change{Nhri::Heading.count}.by(1).
                                           and change{Nhri::Offence.count}.by(0)
  end

  it "while adding a heading it can only populate one offence at a time" do
    add_heading.click
    fill_in('heading_title', :with => "Some new heading text")
    add_offence.click
    add_offence.click
    expect(page).to have_selector('.offence_description', :count => 1)
    page.find('.offence_description').set('Offence text')
    add_offence.click
    expect(page).to have_selector('.offence_description', :count => 2)
    deselect_first_offence
    expect(page).to have_selector('.offence_description', :count => 1)
  end

  it "can cancel the adding of new headings and the entered title and offences are reset" do
    add_heading.click
    fill_in('heading_title', :with => "Some new heading text")
    add_offence.click
    page.find('.offence_description').set('Offence text')
    cancel_add.click
    expect(page).not_to have_selector('#heading_save')
    add_heading.click
    expect(page.find('#heading_title').value).to be_blank
    expect(page).not_to have_selector('.offence_description')
  end

  it "does not validate a blank or whitespace title" do
    add_heading.click
    expect(page).not_to have_selector('#title_error', :text => "Title can't be blank.")
    fill_in('heading_title', :with => "   ")
    expect{save_heading.click; sleep(0.3)}.not_to change{Nhri::Heading.count}
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
    setup_database # 3 headings
    visit nhri_headings_path(:en)
  end

  it "leaves existing headings if adding is cancelled" do # b/c there was a bug!
    expect(page.all('#headings_container .heading').count).to eq 3
    add_heading.click
    cancel_add.click
    add_heading.click
    cancel_add.click
    expect(page.all('#headings_container .heading').count).to eq 3
  end

  it "can delete a heading" do
    expect{delete_heading.click; sleep(0.3)}.to change{Nhri::Heading.count}.by(-1).
                                             and change{page.all('#headings_container .heading').count}.by(-1)
  end

  it "can edit the title of a heading" do
    edit_first_heading.click
    page.find('#heading_title').set("I changed my mind")
    expect{edit_save.click; sleep(0.3)}.to change{Nhri::Heading.first.title}.to("I changed my mind")
    expect(page).to have_selector('#headings_container .heading .title', :text => "I changed my mind")
  end

  it "does not validate if heading title is edited to invalid value" do
    edit_first_heading.click
    page.find('#heading_title').set("  ")
    expect{edit_save.click; sleep(0.3)}.not_to change{Nhri::Heading.first.title}
    expect(page).to have_selector('#title_error', :text => "Title can't be blank.")
  end

  it "restores previous value if editing is started and cancelled" do
    edit_first_heading.click
    page.find('#heading_title').set("I changed my mind")
    edit_cancel.click
    expect(page).to have_selector('#headings_container .heading .title', :text => "My really cool heading")
  end

  it "permits only one heading to be edited at any time" do
    edit_first_heading.click
    edit_second_heading.click
    expect(page.all('input#heading_title').count).to eq 1
  end
end

feature "offences behaviour on headings index page", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include HeadingsSpecHelper

  before do
    setup_database # 3 headings
    visit nhri_headings_path(:en)
    open_first_offences_dropdown
  end

  it "can add offences" do
    add_offence.click
    page.find('#offence_description').set('Offence text')
    expect{edit_save.click; sleep(0.3)}.to change{Nhri::Offence.count}.by 1
    expect(page.all('.offence .description .no_edit span').first.text).to eq "Offence text"
  end

  it "restores new offence form to blank if adding offence is terminated after description was added" do
    add_offence.click
    page.find('#offence_description').set('Offence text')
    terminate_adding_offence
    expect(page).not_to have_selector('#offence_description')
    add_offence.click
    expect(page.find('#offence_description').value).to be_blank
  end

  it "can only add one offence at a time" do
    add_offence.click
    expect(page).to have_selector('input#offence_description', :count => 1)
    add_offence.click
    expect(page).to have_selector('input#offence_description', :count => 1)
  end

  it "shows an error and does not persist the offence when saving with blank description" do
    add_offence.click
    expect{edit_save.click; sleep(0.3)}.not_to change{Nhri::Offence.count}
    expect(page).to have_selector('#description_error', :text => "Description can't be blank")
    page.find('#offence_description').set('Offence text')
    expect(page).not_to have_selector('#description_error', :text => "Description can't be blank")
  end

  it "can delete offences" do
    expect{delete_first_offence.click; sleep(0.2)}.to change{Nhri::Offence.count}.by(-1).
                                                   and change{page.all('.offence').count}.by(-1)
  end

  it "can edit offences" do
    edit_first_offence.click
    fill_in('offence_description', :with=>'Changed my mind')
    expect{edit_save_offence.click; sleep(0.2)}.to change{Nhri::Offence.first.description}.to "Changed my mind"
    expect(page).to have_selector('.offence .description .no_edit span', :text => "Changed my mind")
  end

  it "restores previous value if editing offences is cancelled" do
    original_description = page.find('.offence .description .no_edit span').text
    edit_first_offence.click
    fill_in('offence_description', :with=>'Changed my mind')
    edit_cancel.click
    expect(page).to have_selector('.offence .description .no_edit span', :text => original_description)
  end

  it "adds an error and does not persist offences edited to blank description" do
    edit_first_offence.click
    fill_in('offence_description', :with=>'')
    expect{edit_save_offence.click; sleep(0.2)}.not_to change{Nhri::Offence.first.description}
    expect(page).to have_selector('#description_error', :text => "Description can't be blank")
    fill_in('offence_description', :with=>'boo')
    expect(page).not_to have_selector('#description_error', :text => "Description can't be blank")
  end

  it "restores previous value and terminates editing if offences dropdown is closed" do
    original_description = page.find('.offence .description .no_edit span').text
    edit_first_offence.click
    fill_in('offence_description', :with=>'Changed my mind')
    close_first_offences_dropdown
    sleep(0.3) # css transition
    open_first_offences_dropdown
    expect(page).to have_selector('.offence .description .no_edit span', :text => original_description)
  end

  it "terminates adding offence when user selects edit offence" do
    add_offence.click
    edit_first_offence.click
    expect(page).to have_selector('input#offence_description', :count => 1)
  end

  it "terminates editing offence when user selects add offence" do
    edit_first_offence.click
    add_offence.click
    expect(page).to have_selector('input#offence_description', :count => 1)
  end

end
