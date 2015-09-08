require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/media_admin_spec_helpers'

feature "media admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaAdminSpecHelpers

  scenario "no filetypes configured" do
    visit outreach_media_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
  end

  scenario "filetypes configured" do
    SiteConfig['outreach_media.media_appearances.filetypes']=["pdf"]
    visit outreach_media_admin_path('en')
    expect(page.find('.type').text).to eq 'pdf'
  end

  scenario "add filetype" do
    visit outreach_media_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
    page.find('#outreach_media_filetype_ext').set('docx')
    expect{ new_filetype_button.click; sleep(0.2) }.to change{ SiteConfig['outreach_media.media_appearances.filetypes'] }.from([]).to(["docx"])
    expect(page).not_to have_selector '#empty'
    page.find('#outreach_media_filetype_ext').set('ppt')
    expect{ new_filetype_button.click; sleep(0.2) }.to change{ SiteConfig['outreach_media.media_appearances.filetypes'].length }.from(1).to(2)
  end

  scenario "add duplicate filetype" do
    SiteConfig['outreach_media.media_appearances.filetypes']=["pdf", "doc"]
    visit outreach_media_admin_path('en')
    sleep(0.1)
    page.find('#outreach_media_filetype_ext').set('doc')
    expect{ new_filetype_button.click; sleep(0.2) }.not_to change{ SiteConfig['outreach_media.media_appearances.filetypes'] }
    expect( flash_message ).to eq "Filetype already exists, must be unique."
  end

  scenario "add duplicate filetype" do
    visit outreach_media_admin_path('en')
    sleep(0.1)
    page.find('#outreach_media_filetype_ext').set('a_very_long_filename')
    expect{ new_filetype_button.click; sleep(0.2) }.not_to change{ SiteConfig['outreach_media.media_appearances.filetypes'] }
    expect( flash_message ).to eq "Filetype too long, 4 characters maximum."
  end

  scenario "delete a filetype" do
    SiteConfig['outreach_media.media_appearances.filetypes']=["pdf", "doc"]
    visit outreach_media_admin_path('en')
    delete_filetype("pdf")
    sleep(0.2)
    expect( SiteConfig['outreach_media.media_appearances.filetypes'] ).to eq ["doc"]
    delete_filetype("doc")
    sleep(0.2)
    expect( SiteConfig['outreach_media.media_appearances.filetypes'] ).to eq []
    expect(page).to have_selector '#empty'
  end

  scenario "change filesize" do
    visit outreach_media_admin_path('en')
    set_filesize("22")
    expect{ page.find('#change_filesize').click; sleep(0.2)}.
      to change{ SiteConfig['outreach_media.media_appearances.filesize']}.to(22)
    expect( page.find('span#filesize').text ).to eq "22"
  end
end

feature "media admin when user not permitted", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaAdminSpecHelpers

  before do
    remove_add_delete_fileconfig_permissions
    SiteConfig['outreach_media.media_appearances.filetypes']=["pdf", "doc"]
    visit outreach_media_admin_path('en')
  end

  scenario "update filetypes" do
    page.find('#outreach_media_filetype_ext').set('docx')
    expect{ new_filetype_button.click; sleep(0.2) }.
      not_to change{ SiteConfig['outreach_media.media_appearances.filetypes'] }
    expect( flash_message ).to eq "You don't have permission to complete that action."
    expect(page.all('.type').map(&:text)).not_to include("docx")
  end

  scenario "delete a filetype" do
    expect{ delete_filetype("pdf"); sleep(0.2) }.
      not_to change{ SiteConfig['outreach_media.media_appearances.filetypes'] }
    expect( flash_message ).to eq "You don't have permission to complete that action."
    expect(page.all('.type').map(&:text)).to include("pdf")
  end

  scenario "change filesize" do
    visit outreach_media_admin_path('en')
    default_value = page.find('span#filesize').text
    set_filesize("22")
    expect{ page.find('#change_filesize').click; sleep(0.2)}.
      not_to change{ SiteConfig['outreach_media.media_appearances.filesize']}
    expect( flash_message ).to eq "You don't have permission to complete that action."
    expect( page.find('span#filesize').text ).to eq default_value
  end
end


feature "configure description areas and subareas", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaAdminSpecHelpers

  before do
    create_default_areas
    visit outreach_media_admin_path('en')
    sleep(0.1)
  end

  scenario 'default areas and subareas' do
    expect(page.all('.area .text').map(&:text)).to include "Human Rights"
    expect(page.all('.area .text').map(&:text)).to include "Good Governance"
    expect(page.all('.area .text').map(&:text)).to include "Special Investigations Unit"
    expect(page.all('.area .text').map(&:text)).to include "Corporate Services"
  end

  scenario 'add an area' do
    page.find('#area_name').set('What else')
    expect{ page.find('button#add_area').click; sleep(0.2)}.to change{ Area.count }.by 1
    expect(page.all('.area .text').map(&:text)).to include "What else"
  end

  scenario 'add an area with blank text' do
    expect{ page.find('button#add_area').click; sleep(0.2)}.not_to change{ Area.count }
    expect( page.find('#area_error') ).to have_text "Area can't be blank"
  end

  scenario 'add an area with whitespace text' do
    page.find('#area_name').set('    ')
    expect{ page.find('button#add_area').click; sleep(0.2)}.not_to change{ Area.count }
    expect( page.find('#area_error') ).to have_text "Area can't be blank"
  end

  scenario 'add an area with leading/trailing whitespace' do
    page.find('#area_name').set('     What else       ')
    expect{ page.find('button#add_area').click; sleep(0.2)}.to change{ Area.count }.by 1
    expect(page.all('.area .text').map(&:text)).to include "What else"
  end

  scenario 'blank area error message removed on keydown' do
    page.find('#area_name').set('    ')
    page.find('button#add_area').click
    sleep(0.2)
    expect( page.find('#area_error') ).to have_text "Area can't be blank"
    name_field = page.find("#area_name").native
    name_field.send_keys("!")
    expect( page ).not_to have_selector('#area_error')
  end

  scenario 'view subareas of an area' do
    open_accordion_for_area("Human Rights")
    expect(subareas).to include "Violation"
    expect(subareas).to include "Education activities"
    expect(subareas).to include "Office reports"
    expect(subareas).to include "Universal periodic review"
    expect(subareas).to include "CEDAW"
    expect(subareas).to include "CRC"
    expect(subareas).to include "CRPD"
  end

  scenario 'add a subarea' do
    open_accordion_for_area("Human Rights")
    page.find('#subarea_name').set('Another subarea')
    expect{ page.find('#add_subarea').click; sleep(0.2)}.to change{ Subarea.count }.by 1
    expect(subareas).to include "Another subarea"
  end

  scenario 'add an subarea with blank text' do
    open_accordion_for_area("Human Rights")
    expect{ page.find('#add_subarea').click; sleep(0.2)}.not_to change{ Subarea.count }
    expect( page.find('#subarea_error') ).to have_text "Subarea can't be blank"
  end

  scenario 'add an subarea with whitespace text' do
    open_accordion_for_area("Human Rights")
    page.find('#subarea_name').set('   ')
    expect{ page.find('#add_subarea').click; sleep(0.2)}.not_to change{ Subarea.count }
    expect( page.find('#subarea_error') ).to have_text "Subarea can't be blank"
  end

  scenario 'add an subarea with leading/trailing whitespace' do
    open_accordion_for_area("Human Rights")
    page.find('#subarea_name').set('    Another subarea   ')
    expect{ page.find('#add_subarea').click; sleep(0.2)}.to change{ Subarea.count }.by 1
    expect(subareas).to include "Another subarea"
  end

  scenario 'blank subarea error message removed on keydown' do
    open_accordion_for_area("Human Rights")
    page.find('#add_subarea').click
    sleep(0.2)
    expect( page.find('#subarea_error') ).to have_text "Subarea can't be blank"
    name_field = page.find("#subarea_name").native
    name_field.send_keys("!")
    expect( page ).not_to have_selector('#subarea_error', :visible => true)
  end
end
