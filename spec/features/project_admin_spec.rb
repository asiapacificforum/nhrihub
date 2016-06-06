require 'rails_helper'
require 'login_helpers'
require 'project_admin_spec_helpers'
require 'navigation_helpers'

feature "project admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ProjectAdminSpecHelpers
  before do
    ['good_governance', 'human_rights', 'special_investigations_unit'].each do |key|
      Mandate.create(:key => key)
    end
  end

  scenario "no filetypes configured" do
    visit project_admin_path('en')
    expect(page).to have_selector '#filetypes #empty'
  end

  scenario "filetypes configured" do
    SiteConfig["project_document.filetypes"]=["pdf"]
    visit project_admin_path('en')
    expect(page.find('.type').text).to eq 'pdf'
  end

  scenario "add filetype" do
    visit project_admin_path('en')
    expect(page).to have_selector '#filetypes #empty'
    page.find('#filetype_ext').set('docx')
    expect{ new_filetype_button.click; wait_for_ajax }.to change{ SiteConfig["project_document.filetypes"] }.from([]).to(["docx"])
    expect(page).not_to have_selector '#filetypes #empty'
    page.find('#filetype_ext').set('ppt')
    expect{ new_filetype_button.click; wait_for_ajax }.to change{ SiteConfig["project_document.filetypes"].length }.from(1).to(2)
  end

  scenario "add duplicate filetype" do
    SiteConfig["project_document.filetypes"]=["pdf", "doc"]
    visit project_admin_path('en')
    page.find('#filetype_ext').set('doc')
    expect{ new_filetype_button.click; wait_for_ajax }.not_to change{ SiteConfig["project_document.filetypes"] }
    expect( flash_message ).to eq "Filetype already exists, must be unique."
  end

  scenario "add invalid filetype" do
    visit project_admin_path('en')
    page.find('#filetype_ext').set('a_very_long_filename')
    expect{ new_filetype_button.click; wait_for_ajax }.not_to change{ SiteConfig["project_document.filetypes"] }
    expect( flash_message ).to eq "Filetype too long, 4 characters maximum."
  end

  scenario "delete a filetype" do
    SiteConfig["project_document.filetypes"]=["pdf", "doc"]
    visit project_admin_path('en')
    delete_filetype("pdf")
    wait_for_ajax
    expect( SiteConfig["project_document.filetypes"] ).to eq ["doc"]
    delete_filetype("doc")
    wait_for_ajax
    expect( SiteConfig["project_document.filetypes"] ).to eq []
    expect(page).to have_selector '#filetypes #empty'
  end

  scenario "change filesize" do
    visit project_admin_path('en')
    set_filesize("22")
    expect{ page.find('#change_filesize').click; wait_for_ajax}.
      to change{ SiteConfig["project_document.filesize"]}.to(22)
    expect( page.find('span#filesize').text ).to eq "22"
  end

  scenario "add good governance project type" do
    visit project_admin_path('en')
    expect(page).to have_selector '.good_governance_project_types #empty'
    page.find('#good_governance_project_type_name').set('some random text')
    new_good_governance_project_type_button = page.find('#new_good_governance_project_type button')
    expect{ new_good_governance_project_type_button.click; wait_for_ajax }.to change{ ProjectType.good_governance.all.map(&:name) }.from([]).to(["some random text"])
    expect(page).not_to have_selector '.good_governance_project_types #empty'
    expect(page).to have_selector '#good_governance_project_types .good_governance_project_type', :text => "some random text"
  end

  scenario "delete good governance project type" do
    ['mooky', 'balooky'].each do |name|
      Mandate.find_by(:key => 'good_governance').project_types.create(:name => name)
    end
    visit project_admin_path('en')
    expect(page).to have_selector '#good_governance_project_types .good_governance_project_type', :text => "mooky"
    expect(page).to have_selector '#good_governance_project_types .good_governance_project_type', :text => "balooky"
    expect{ delete_project_type("mooky"); wait_for_ajax }.to change{ ProjectType.good_governance.count }.by(-1)
    expect{ delete_project_type("balooky"); wait_for_ajax }.to change{ ProjectType.good_governance.count }.by(-1)
    expect(page).to have_selector '.good_governance_project_types #empty'
  end

  scenario "add human rights project type" do
    visit project_admin_path('en')
    expect(page).to have_selector '.human_rights_project_types #empty'
    page.find('#human_rights_project_type_name').set('some random text')
    new_human_rights_project_type_button = page.find('#new_human_rights_project_type button')
    expect{ new_human_rights_project_type_button.click; wait_for_ajax }.to change{ ProjectType.human_rights.all.map(&:name) }.from([]).to(["some random text"])
    expect(page).not_to have_selector '.human_rights_project_types #empty'
    expect(page).to have_selector '#human_rights_project_types .human_rights_project_type', :text => "some random text"
  end

  scenario "delete human rights project type" do
    ['mooky', 'balooky'].each do |name|
      Mandate.find_by(:key => 'human_rights').project_types.create(:name => name)
    end
    visit project_admin_path('en')
    expect(page).to have_selector '#human_rights_project_types .human_rights_project_type', :text => "mooky"
    expect(page).to have_selector '#human_rights_project_types .human_rights_project_type', :text => "balooky"
    expect{ delete_project_type("mooky"); wait_for_ajax }.to change{ ProjectType.human_rights.count }.by(-1)
    expect{ delete_project_type("balooky"); wait_for_ajax }.to change{ ProjectType.human_rights.count }.by(-1)
    expect(page).to have_selector '.human_rights_project_types #empty'
  end

  scenario "add siu project type" do
    visit project_admin_path('en')
    expect(page).to have_selector '.special_investigations_unit_project_types #empty'
    page.find('#special_investigations_unit_project_type_name').set('some random text')
    new_special_investigations_unit_project_type_button = page.find('#new_special_investigations_unit_project_type button')
    expect{ new_special_investigations_unit_project_type_button.click; wait_for_ajax }.to change{ ProjectType.siu.all.map(&:name) }.from([]).to(["some random text"])
    expect(page).not_to have_selector '.special_investigations_unit_project_types #empty'
    expect(page).to have_selector '#special_investigations_unit_project_types .special_investigations_unit_project_type', :text => "some random text"
  end

  scenario "delete siu project type" do
    ['mooky', 'balooky'].each do |name|
      Mandate.find_by(:key => 'special_investigations_unit').project_types.create(:name => name)
    end
    visit project_admin_path('en')
    expect(page).to have_selector '#special_investigations_unit_project_types .special_investigations_unit_project_type', :text => "mooky"
    expect(page).to have_selector '#special_investigations_unit_project_types .special_investigations_unit_project_type', :text => "balooky"
    expect{ delete_project_type("mooky"); wait_for_ajax }.to change{ ProjectType.siu.count }.by(-1)
    expect{ delete_project_type("balooky"); wait_for_ajax }.to change{ ProjectType.siu.count }.by(-1)
    expect(page).to have_selector '.special_investigations_unit_project_types #empty'
  end
    #gg_types = ["Own motion investigation", "Consultation", "Awareness Raising", "Other"]
    #hr_types = ["Schools", "Report or Inquiry", "Awareness Raising", "Legislative Review",
                #"Amicus Curiae", "Convention Implementation", "UN Reporting", "Detention Facilities Inspection",
                #"State of Human Rights Report", "Other"]
    #siu_types = ["PSU Review", "Report", "Inquiry", "Other"]
end
