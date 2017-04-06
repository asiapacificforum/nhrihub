require 'rails_helper'
$:.unshift File.expand_path '../../helpers', __FILE__
require 'projects_spec_helpers'
require 'login_helpers'
require 'navigation_helpers'
require 'projects_spec_common_helpers'
require 'upload_file_helpers'

feature "new project file management", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ProjectsSpecHelpers
  include IERemoteDetector
  include NavigationHelpers
  include ProjectsSpecCommonHelpers
  include UploadFileHelpers

  it "should remove a selected file" do
    add_project.click

    within new_project do
      attach_file("project_fileinput", upload_document)
      fill_in("project_document_title", :with => "Project Document")
      expect(page).to have_selector("#documents .document .filename", :text => "upload_file.pdf")
    end

    within new_project do
      attach_file("project_fileinput", upload_document)
      page.all("#project_document_title")[1].set("Title for an analysis document")
      expect(page).to have_selector("#documents .document .filename", :text => "upload_file.pdf", :count => 2)
    end

    page.all("#documents .document .remove")[0].click
    expect(page).to have_selector("#documents .document .filename", :text => "upload_file.pdf", :count => 1)
    page.all("#documents .document .remove")[0].click
    expect(page).not_to have_selector("#documents .document .filename", :text => "upload_file.pdf")
  end

  it "shows filesize error if file is too big" do
    add_project.click
    within new_project do
      attach_file("project_fileinput", big_upload_document)
    end
    expect(page).to have_selector('#filesize_error', :text => "File is too large")
  end

  it "shows filetype error for unpermitted file type" do
    set_permitted_filetypes # ['anything']
    add_project.click
    within new_project do
      attach_file("project_fileinput", upload_image)
    end
    expect(page).to have_selector('#filetype_error', :text =>  "File type not allowed")
  end

  it "shows no filetypes configured error if no filetypes have been configured" do
    reset_permitted_filetypes # []
    add_project.click
    within new_project do
      attach_file("project_fileinput", upload_document)
    end
    expect(page).to have_selector('#unconfigured_filetypes_error', :text => "No permitted file types have been configured")
  end

  #it "prevents duplicate named files from being added" do
    
  #end
end
