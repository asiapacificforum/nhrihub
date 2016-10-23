require 'login_helpers'
require 'navigation_helpers'
require 'projects_spec_common_helpers'
require 'upload_file_helpers'

RSpec.shared_examples "existing project file management" do
  include IERemoteDetector
  #include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  include ProjectsSpecCommonHelpers
  include UploadFileHelpers

  it "should upload new files" do
    edit_first_project.click
    within edit_documents do
      #attach_file
      attach_file("project_fileinput", upload_document)
    end
    page.find("#project_document_title").set("New uploaded document")
    expect{ edit_save.click; wait_for_ajax }.to change{ Project.first.project_documents.count }.from(2).to(3)
    expect(Project.first.project_documents.map(&:title)).to include "New uploaded document"
    expect(all('.project_document .title').map(&:text)).to include "New uploaded document"
  end

  it "shows filesize error if file is too big" do
    edit_first_project.click
    add_project.click
    within new_project do
      #page.attach_file("project_file", big_upload_document, :visible => false)
      attach_file("project_fileinput", big_upload_document)
    end
    expect(page).to have_selector('#filesize_error', :text => "File is too large")
  end

  it "shows filetype error for unpermitted file type" do
    set_permitted_filetypes # ['anything']
    edit_first_project.click
    add_project.click
    within new_project do
      #page.attach_file("project_file", upload_image, :visible => false)
      attach_file("project_fileinput", upload_image)
    end
    expect(page).to have_selector('#filetype_error', :text =>  "File type not allowed")
  end

  it "replaces named files" do
    edit_last_project.click
    within edit_documents do
      #attach_file
      attach_file("project_fileinput", upload_document)
    end
    page.find("#project_document_title").set("Final Report")
    expect{ edit_save.click; wait_for_ajax }.not_to change{ ProjectDocument.count }
  end

  it "adds files to the files list if they are not 'named files'" do
    edit_last_project.click
    within edit_documents do
      #attach_file
      attach_file("project_fileinput", upload_document)
    end
    page.find("#project_document_title").set("Any old title")
    expect{ edit_save.click; wait_for_ajax }.to change{ ProjectDocument.count }.by(1)
  end

  it "should delete files" do
    edit_last_project.click
    expect{ delete_file.click; confirm_deletion; wait_for_ajax }.to change{ ProjectDocument.count }.by(-1).
                                                                and change{ project_documents.all('.project_document').count }.by(-1)
  end

  # can't test download in chrome or firefox
  it "can download the saved document", :driver => :poltergeist do
    @doc = Project.last.project_documents.first
    expand_last_project
    click_the_download_icon
    expect(page.response_headers['Content-Type']).to eq('application/pdf')
    filename = @doc.filename
    expect(page.response_headers['Content-Disposition']).to eq("attachment; filename=\"#{filename}\"")
  end

  it "panel expanding should behave" do
    edit_first_project.click
    edit_save.click
    wait_for_ajax
    expect(page.evaluate_script("projects.findAllComponents('project')[0].get('expanded')")).to eq true
    expect(page.evaluate_script("projects.findAllComponents('project')[0].get('editing')")).to eq false
    edit_first_project.click
    expect(page.evaluate_script("projects.findAllComponents('project')[0].get('expanded')")).to eq true
    expect(page.evaluate_script("projects.findAllComponents('project')[0].get('editing')")).to eq true
  end
end
