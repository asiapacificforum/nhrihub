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
    expect(page).to have_selector '#good_governance_subareas #empty'
    expect(page).to have_selector '#siu_subareas #empty'
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
    expect(page.find('#good_governance_subareas .good_governance_subarea').text).to eq "foo"
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
    expect(page).to have_selector '#good_governance_subareas #empty'
    page.find('#good_governance_subareas #good_governance_subarea_name').set('A thing')
    expect{ new_gg_complaint_subarea_button.click; wait_for_ajax }.to change{ GoodGovernance::ComplaintBasis.all.map(&:name) }.from([]).to(["A thing"])
    expect(page.find('#good_governance_subareas .good_governance_subarea').text).to eq "A thing"
    expect(page).not_to have_selector '#good_governance_subareas #empty'
    page.find('#good_governance_subareas #good_governance_subarea_name').set('Another thing')
    expect{ new_gg_complaint_subarea_button.click; wait_for_ajax }.to change{ GoodGovernance::ComplaintBasis.count }.from(1).to(2)
    expect(page.all('#good_governance_subareas .good_governance_subarea')[1].text).to eq "Another thing"
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
    page.find('#good_governance_subareas #good_governance_subarea_name').set('A thing')
    expect{ new_gg_complaint_subarea_button.click; wait_for_ajax }.not_to change{ GoodGovernance::ComplaintBasis.count }
    expect( flash_message ).to eq "Complaint basis already exists, must be unique."
  end

  scenario "add duplicate complaint basis under different mandate" do
    Siu::ComplaintBasis.create(:name => "A thing")
    visit complaint_admin_path('en')
    sleep(0.1)
    page.find('#good_governance_subareas #good_governance_subarea_name').set('A thing')
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
    expect(page).to have_selector '#good_governance_subareas #empty'
  end

  scenario "delete a corporate services complaint basis" do
    CorporateServices::ComplaintBasis.create(:name => "A thing")
    visit complaint_admin_path('en')
    expect{ delete_complaint_subarea("A thing").click; wait_for_ajax }.to change{ CorporateServices::ComplaintBasis.count }.by -1
    expect(page).to have_selector '#corporate_services_subareas #empty'
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

feature "agency admin", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ComplaintAdminSpecHelpers
  scenario "none configured yet" do
    visit complaint_admin_path('en')
    expect(page).to have_selector("h4",:text=>"Agencies")
    expect(page).to have_selector('#agencies td#empty', :text => "None configured")
  end

  scenario "some agencies are configured" do
    FactoryGirl.create(:agency, :name => "ABC", :full_name => "Anywhere But Colma")
    visit complaint_admin_path('en')
    expect(page).to have_selector('#agencies .agency td.name', :text => 'ABC')
    expect(page).to have_selector('#agencies .agency td.full_name', :text => 'Anywhere But Colma')
  end

  scenario "add a valid agency" do
    visit complaint_admin_path('en')
    page.find('form#new_agency input#agency_name').set('ABC')
    page.find('form#new_agency input#agency_full_name').set('Anywhere But Calaveras')
    expect{page.find('button#add_agency').click; wait_for_ajax}.to change{Agency.count}.from(0).to(1)
    expect(page).not_to have_selector('#agencies td#empty', :text => "None configured")
    expect(page).to have_selector('#agencies .agency td.name', :text => 'ABC')
    expect(page).to have_selector('#agencies .agency td.full_name', :text => 'Anywhere But Calaveras')
    expect(page.find('form#new_agency input#agency_name').value).to eq ''
    expect(page.find('form#new_agency input#agency_full_name').value).to eq ''
  end

  scenario "add an invalid agency (blank name)" do
    visit complaint_admin_path('en')
    page.find('form#new_agency input#agency_name').set('ABC')
    expect{page.find('button#add_agency').click; wait_for_ajax}.not_to change{Agency.count}
    expect(page).to have_selector('#invalid_agency_error', :text => "fields cannot be blank")
    page.find('form#new_agency input#agency_full_name').click
    expect(page).not_to have_selector('#invalid_agency_error')
  end

  scenario "add an invalid agency (blank name)" do
    visit complaint_admin_path('en')
    page.find('form#new_agency input#agency_full_name').set('Anywhere But Chelmsford')
    expect{page.find('button#add_agency').click; wait_for_ajax}.not_to change{Agency.count}
    expect(page).to have_selector('#invalid_agency_error', :text => "fields cannot be blank")
    page.find('form#new_agency input#agency_name').click
    expect(page).not_to have_selector('#invalid_agency_error')
  end

  scenario "add an agency with duplicate name" do
    FactoryGirl.create(:agency, :name => "ABC", :full_name => "Anywhere But Colma")
    visit complaint_admin_path('en')
    page.find('form#new_agency input#agency_name').set('abc') # case insensitive
    page.find('form#new_agency input#agency_full_name').set('Anywhere But Chelmsford')
    expect{page.find('button#add_agency').click; wait_for_ajax}.not_to change{Agency.count}
    expect(page).to have_selector('#duplicate_agency_error', :text => "duplicate agency not allowed")
    page.find('form#new_agency input#agency_name').click
    expect(page).not_to have_selector('#duplicate_agency_error')
  end

  scenario "add an agency with duplicate full name" do
    FactoryGirl.create(:agency, :name => "ABC", :full_name => "Anywhere But Colma")
    visit complaint_admin_path('en')
    page.find('form#new_agency input#agency_name').set('XYZ')
    page.find('form#new_agency input#agency_full_name').set('Anywhere But colma') # case insensitive!
    expect{page.find('button#add_agency').click; wait_for_ajax}.not_to change{Agency.count}
    expect(page).to have_selector('#duplicate_agency_error', :text => "duplicate agency not allowed")
    page.find('form#new_agency input#agency_full_name').click
    expect(page).not_to have_selector('#duplicate_agency_error')
  end

  scenario "delete an agency that is not associated with any complaint" do
    FactoryGirl.create(:agency, :name => "ABC", :full_name => "Anywhere But Colma")
    visit complaint_admin_path('en')
    expect{page.find("#agencies .agency .delete_agency").click; wait_for_ajax}.to change{Agency.count}.from(1).to(0)
  end

  scenario "delete an agency that is already associated with a complaint" do
    agency = FactoryGirl.create(:agency, :name => "ABC", :full_name => "Anywhere But Colma")
    FactoryGirl.create(:complaint, :agencies => [agency])
    visit complaint_admin_path('en')
    expect{page.find("#agencies .agency .delete_agency").click; wait_for_ajax}.not_to change{Agency.count}
    expect(page).to have_selector('#delete_disallowed', :text => "cannot delete an agency that is associated with complaints")
    page.find('body').click # click anywhere
    expect(page).not_to have_selector('#delete_disallowed')
  end
end
