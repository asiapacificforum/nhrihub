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
    add_attribute.click
    page.find('.attribute_description').set('HumanRightsAttribute text')
    add_attribute.click
    page.all('.attribute_description')[0].set('Second attribute text')
    expect{save_heading.click; sleep(0.3)}.to change{Nhri::Heading.count}.by(1).
                                           and change{Nhri::HumanRightsAttribute.count}.by(2)
    expect(Nhri::Heading.first.human_rights_attributes.count).to eq 2
    expect(Nhri::Heading.first.title).to eq "Some new heading text"
    expect(Nhri::Heading.first.human_rights_attributes.map(&:description)).to include "HumanRightsAttribute text"
    expect(Nhri::Heading.first.human_rights_attributes.map(&:description)).to include "Second attribute text"
    expect(page).to have_selector('#headings_container .heading', :count => 1)
    expect(page).to have_selector('#headings_container .heading .title', :text => "Some new heading text")
  end

  it "can add new headings with no human_rights_attributes" do
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

  it "does not persist empty human_rights_attributes" do
    add_heading.click
    fill_in('heading_title', :with => "Some new heading text")
    add_attribute.click
    expect{save_heading.click; sleep(0.3)}.to change{Nhri::Heading.count}.by(1).
                                           and change{Nhri::HumanRightsAttribute.count}.by(0)
  end

  it "while adding a heading it can only populate one attribute at a time" do
    add_heading.click
    fill_in('heading_title', :with => "Some new heading text")
    add_attribute.click
    add_attribute.click
    expect(page).to have_selector('.attribute_description', :count => 1)
    page.find('.attribute_description').set('HumanRightsAttribute text')
    add_attribute.click
    expect(page).to have_selector('.attribute_description', :count => 2)
    deselect_first_attribute
    expect(page).to have_selector('.attribute_description', :count => 1)
  end

  it "can cancel the adding of new headings and the entered title and human_rights_attributes are reset" do
    add_heading.click
    fill_in('heading_title', :with => "Some new heading text")
    add_attribute.click
    page.find('.attribute_description').set('HumanRightsAttribute text')
    cancel_add.click
    expect(page).not_to have_selector('#heading_save')
    add_heading.click
    expect(page.find('#heading_title').value).to be_blank
    expect(page).not_to have_selector('.attribute_description')
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

feature "attributes behaviour on headings index page", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include HeadingsSpecHelper

  before do
    setup_database # 3 headings
    visit nhri_headings_path(:en)
    open_first_attributes_dropdown
  end

  it "can add attributes" do
    add_attribute.click
    page.find('#attribute_description').set('HumanRightsAttribute text')
    expect{edit_save.click; sleep(0.3)}.to change{Nhri::HumanRightsAttribute.count}.by 1
    expect(page.all('.attribute .description .no_edit span').first.text).to eq "HumanRightsAttribute text"
  end

  it "restores new attribute form to blank if adding attribute is terminated after description was added" do
    add_attribute.click
    page.find('#attribute_description').set('HumanRightsAttribute text')
    terminate_adding_attribute
    expect(page).not_to have_selector('#attribute_description')
    add_attribute.click
    expect(page.find('#attribute_description').value).to be_blank
  end

  it "can only add one attribute at a time" do
    add_attribute.click
    expect(page).to have_selector('input#attribute_description', :count => 1)
    add_attribute.click
    expect(page).to have_selector('input#attribute_description', :count => 1)
  end

  it "shows an error and does not persist the attribute when saving with blank description" do
    add_attribute.click
    expect{edit_save.click; sleep(0.3)}.not_to change{Nhri::HumanRightsAttribute.count}
    expect(page).to have_selector('#description_error', :text => "Description can't be blank")
    page.find('#attribute_description').set('HumanRightsAttribute text')
    expect(page).not_to have_selector('#description_error', :text => "Description can't be blank")
  end

  it "can delete attributes" do
    expect{delete_first_attribute.click; sleep(0.2)}.to change{Nhri::HumanRightsAttribute.count}.by(-1).
                                                   and change{page.all('.attribute').count}.by(-1)
  end

  it "can edit attributes" do
    edit_first_attribute.click
    fill_in('attribute_description', :with=>'Changed my mind')
    expect{edit_save_attribute.click; sleep(0.2)}.to change{Nhri::HumanRightsAttribute.first.description}.to "Changed my mind"
    expect(page).to have_selector('.attribute .description .no_edit span', :text => "Changed my mind")
  end

  it "restores previous value if editing attributes is cancelled" do
    original_description = page.all('.attribute .description .no_edit span').first.text
    edit_first_attribute.click
    fill_in('attribute_description', :with=>'Changed my mind')
    edit_cancel.click
    expect(page).to have_selector('.attribute .description .no_edit span', :text => original_description)
  end

  it "adds an error and does not persist attributes edited to blank description" do
    edit_first_attribute.click
    fill_in('attribute_description', :with=>'')
    expect{edit_save_attribute.click; sleep(0.2)}.not_to change{Nhri::HumanRightsAttribute.first.description}
    expect(page).to have_selector('#description_error', :text => "Description can't be blank")
    fill_in('attribute_description', :with=>'boo')
    expect(page).not_to have_selector('#description_error', :text => "Description can't be blank")
  end

  it "restores previous value and terminates editing if attributes dropdown is closed" do
    original_description = page.all('.attribute .description .no_edit span').first.text
    edit_first_attribute.click # show
    fill_in('attribute_description', :with=>'Changed my mind')
    sleep(0.3) # due to unknown timing condition in bootsrap collapse
    close_first_attributes_dropdown
    sleep(0.3) # due to unknown timing condition in bootsrap collapse
    open_first_attributes_dropdown
    expect(page).to have_selector('.attribute .description .no_edit span', :text => original_description)
  end

  it "terminates adding attribute when user selects edit attribute" do
    add_attribute.click
    edit_first_attribute.click
    expect(page).to have_selector('input#attribute_description', :count => 1)
  end

  it "terminates editing attribute when user selects add attribute" do
    edit_first_attribute.click
    add_attribute.click
    expect(page).to have_selector('input#attribute_description', :count => 1)
    # b/c there was a bug test this..
    add_attribute.click
    expect(page).not_to have_selector("#description_error")
    expect(page).to have_selector("#attributes .attribute", :count => 3)
  end

end
