require 'rails_helper'
$:.unshift File.expand_path '../../helpers', __FILE__
require 'login_helpers'
require 'complaint_admin_spec_helpers'
require 'navigation_helpers'
require 'complaint_context_file_admin_spec_helpers'
require 'communication_context_file_admin_spec_helpers'
require 'shared_behaviours/file_admin_behaviour'

feature "complaint bases admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ComplaintAdminSpecHelpers

  scenario "no complaint bases configured" do
    visit complaint_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#gg_subareas #empty'
    expect(page).to have_selector '#siu_subareas #empty'
    expect(page).to have_selector '#complaint_categories #empty'
    expect(page).to have_selector '#corporate_services_subareas #empty'
  end

  scenario "special investigations unit complaint bases configured" do
    Siu::ComplaintBasis.create(:name=>"foo")
    visit complaint_admin_path('en')
    expect(page.find('#siu_subareas .siu_subarea').text).to eq "foo"
  end

  scenario "good governance complaint bases configured" do
    GoodGovernance::ComplaintBasis.create(:name=>"foo")
    visit complaint_admin_path('en')
    expect(page.find('#gg_subareas .gg_subarea').text).to eq "foo"
  end

  scenario "corporate services complaint bases configured" do
    CorporateServices::ComplaintBasis.create(:name=>"foo")
    visit complaint_admin_path('en')
    expect(page.find('#corporate_services_subareas .corporate_services_subarea').text).to eq "foo"
  end

  scenario "add siu complaint basis" do
    visit complaint_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#siu_subareas #empty'
    page.find('#siu_subareas #siu_subarea_name').set('A thing')
    expect{ new_siu_complaint_subarea_button.click; wait_for_ajax }.to change{ Siu::ComplaintBasis.all.map(&:name) }.from([]).to(["A thing"])
    expect(page.find('#siu_subareas .siu_subarea').text).to eq "A thing"
    expect(page).not_to have_selector '#siu_subareas #empty'
    page.find('#siu_subareas #siu_subarea_name').set('Another thing')
    expect{ new_siu_complaint_subarea_button.click; wait_for_ajax }.to change{ Siu::ComplaintBasis.count }.from(1).to(2)
    expect(page.all('#siu_subareas .siu_subarea')[1].text).to eq "Another thing"
  end

  scenario "add gg complaint basis" do
    visit complaint_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#gg_subareas #empty'
    page.find('#gg_subareas #gg_subarea_name').set('A thing')
    expect{ new_gg_complaint_subarea_button.click; wait_for_ajax }.to change{ GoodGovernance::ComplaintBasis.all.map(&:name) }.from([]).to(["A thing"])
    expect(page.find('#gg_subareas .gg_subarea').text).to eq "A thing"
    expect(page).not_to have_selector '#gg_subareas #empty'
    page.find('#gg_subareas #gg_subarea_name').set('Another thing')
    expect{ new_gg_complaint_subarea_button.click; wait_for_ajax }.to change{ GoodGovernance::ComplaintBasis.count }.from(1).to(2)
    expect(page.all('#gg_subareas .gg_subarea')[1].text).to eq "Another thing"
  end

  scenario "add corporate services complaint basis" do
    visit complaint_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#corporate_services_subareas #empty'
    page.find('#corporate_services_subareas #corporate_services_subarea_name').set('A thing')
    expect{ new_corporate_services_complaint_subarea_button.click; wait_for_ajax }.to change{ CorporateServices::ComplaintBasis.all.map(&:name) }.from([]).to(["A thing"])
    expect(page.find('#corporate_services_subareas .corporate_services_subarea').text).to eq "A thing"
    expect(page).not_to have_selector '#corporate_services_subareas #empty'
    page.find('#corporate_services_subareas #corporate_services_subarea_name').set('Another thing')
    expect{ new_corporate_services_complaint_subarea_button.click; wait_for_ajax }.to change{ CorporateServices::ComplaintBasis.count }.from(1).to(2)
    expect(page.all('#corporate_services_subareas .corporate_services_subarea')[1].text).to eq "Another thing"
  end

  scenario "add duplicate complaint basis under same mandate" do
    GoodGovernance::ComplaintBasis.create(:name => "A thing")
    visit complaint_admin_path('en')
    sleep(0.1)
    page.find('#gg_subareas #gg_subarea_name').set('A thing')
    expect{ new_gg_complaint_subarea_button.click; wait_for_ajax }.not_to change{ GoodGovernance::ComplaintBasis.count }
    expect( flash_message ).to eq "Complaint basis already exists, must be unique."
  end

  scenario "add duplicate complaint basis under different mandate" do
    Siu::ComplaintBasis.create(:name => "A thing")
    visit complaint_admin_path('en')
    sleep(0.1)
    page.find('#gg_subareas #gg_subarea_name').set('A thing')
    expect{ new_gg_complaint_subarea_button.click; wait_for_ajax }.to change{ GoodGovernance::ComplaintBasis.count }.by(1)
  end

  scenario "delete an siu complaint basis" do
    Siu::ComplaintBasis.create(:name => "A thing")
    visit complaint_admin_path('en')
    expect{ delete_complaint_subarea("A thing").click; wait_for_ajax }.to change{ Siu::ComplaintBasis.count }.by -1
    expect(page).to have_selector '#siu_subareas #empty'
  end

  scenario "delete a good governance complaint basis" do
    GoodGovernance::ComplaintBasis.create(:name => "A thing")
    visit complaint_admin_path('en')
    expect{ delete_complaint_subarea("A thing").click; wait_for_ajax }.to change{ GoodGovernance::ComplaintBasis.count }.by -1
    expect(page).to have_selector '#gg_subareas #empty'
  end

  scenario "delete a corporate services complaint basis" do
    CorporateServices::ComplaintBasis.create(:name => "A thing")
    visit complaint_admin_path('en')
    expect{ delete_complaint_subarea("A thing").click; wait_for_ajax }.to change{ CorporateServices::ComplaintBasis.count }.by -1
    expect(page).to have_selector '#corporate_services_subareas #empty'
  end
end

feature "complaint categories admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ComplaintAdminSpecHelpers

  scenario "complaint categories configured" do
    ComplaintCategory.create(:name=>"foo")
    visit complaint_admin_path('en')
    expect(page.find('#complaint_categories .complaint_category').text).to eq "foo"
  end

  scenario "add complaint category" do
    visit complaint_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#complaint_categories #empty'
    page.find('#complaint_categories #complaint_category_name').set('A thing')
    expect{ new_complaint_category_button.click; wait_for_ajax }.to change{ ComplaintCategory.all.map(&:name) }.from([]).to(["A thing"])
    expect(page.find('#complaint_categories .complaint_category').text).to eq "A thing"
    expect(page).not_to have_selector '#complaint_categories #empty'
    page.find('#complaint_categories #complaint_category_name').set('Another thing')
    expect{ new_complaint_category_button.click; wait_for_ajax }.to change{ ComplaintCategory.count }.from(1).to(2)
    expect(page.all('#complaint_categories .complaint_category')[1].text).to eq "Another thing"
  end

  scenario "add duplicate complaint category" do
    ComplaintCategory.create(:name => "A thing")
    visit complaint_admin_path('en')
    sleep(0.1)
    page.find('#complaint_categories #complaint_category_name').set('A thing')
    expect{ new_complaint_category_button.click; wait_for_ajax }.not_to change{ ComplaintCategory.count }
    expect( flash_message ).to eq "Complaint category already exists, must be unique."
  end

  scenario "delete a complaint category" do
    ComplaintCategory.create(:name => "A thing")
    visit complaint_admin_path('en')
    expect{ delete_complaint_subarea("A thing").click; wait_for_ajax }.to change{ ComplaintCategory.count }.by -1
    expect(page).to have_selector '#complaint_categories #empty'
  end
end

feature "complaint file admin", :js => true do
  include ComplaintAdminSpecHelpers
  include ComplaintContextFileAdminSpecHelpers
  it_should_behave_like "file admin"
end

feature "communication file admin", :js => true do
  include ComplaintAdminSpecHelpers
  include CommunicationContextFileAdminSpecHelpers
  it_should_behave_like "file admin"
end
