require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'

feature "media admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user

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

def new_filetype_button
  page.find("#new_outreach_media_filetype table button")
end

def set_filesize(val)
  page.find('input#filesize').set(val)
end

def delete_filetype(type)
  page.find(:xpath, ".//tr[contains(td,'#{type}')]").find('a').click
end

def remove_add_delete_fileconfig_permissions
  ActionRole.
    joins(:action => :controller).
    where('actions.action_name' => ['create', 'destroy', 'update'],
          'controllers.controller_name' => ['outreach_media/media_appearances/filetypes','outreach_media/media_appearances/filesizes']).
    destroy_all
end
