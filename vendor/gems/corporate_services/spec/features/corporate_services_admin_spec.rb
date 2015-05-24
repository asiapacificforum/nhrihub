require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'

feature "internal document admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers

  scenario "no filetypes configured" do
    visit corporate_services_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
  end

  scenario "filetypes configured" do
    SiteConfig['corporate_services.internal_documents.filetypes']=["pdf"]
    visit corporate_services_admin_path('en')
    expect(page.find('.type').text).to eq 'pdf'
  end

  scenario "add filetype" do
    visit corporate_services_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#empty'
    page.find('#filetype_ext').set('docx')
    expect{ page.find("#new_filetype table button").click; sleep(0.2) }.to change{ SiteConfig['corporate_services.internal_documents.filetypes'] }.from([]).to(["docx"])
    expect(page).not_to have_selector '#empty'
    page.find('#filetype_ext').set('ppt')
    expect{ page.find("#new_filetype table button").click; sleep(0.2) }.to change{ SiteConfig['corporate_services.internal_documents.filetypes'].length }.from(1).to(2)
  end

  scenario "delete a filetype" do
    SiteConfig['corporate_services.internal_documents.filetypes']=["pdf", "doc"]
    visit corporate_services_admin_path('en')
    delete_filetype("pdf")
    sleep(0.2)
    expect( SiteConfig['corporate_services.internal_documents.filetypes'] ).to eq ["doc"]
    delete_filetype("doc")
    sleep(0.2)
    expect( SiteConfig['corporate_services.internal_documents.filetypes'] ).to eq []
    expect(page).to have_selector '#empty'
  end

end

def delete_filetype(type)
  page.find(:xpath, ".//tr[contains(td,'#{type}')]").find('a').click
end
