require 'rails_helper'
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
    expect(page).to have_selector '#gg_bases #empty'
    expect(page).to have_selector '#siu_bases #empty'
    expect(page).to have_selector '#complaint_categories #empty'
  end

  scenario "complaint bases configured" do
    Siu::ComplaintBasis.create(:name=>"foo")
    visit complaint_admin_path('en')
    expect(page.find('#siu_bases .siu_basis').text).to eq "foo"
  end

  scenario "add siu complaint basis" do
    visit complaint_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#siu_bases #empty'
    page.find('#siu_bases #siu_basis_name').set('A thing')
    expect{ new_siu_complaint_basis_button.click; wait_for_ajax }.to change{ Siu::ComplaintBasis.all.map(&:name) }.from([]).to(["A thing"])
    expect(page.find('#siu_bases .siu_basis').text).to eq "A thing"
    expect(page).not_to have_selector '#siu_bases #empty'
    page.find('#siu_bases #siu_basis_name').set('Another thing')
    expect{ new_siu_complaint_basis_button.click; wait_for_ajax }.to change{ Siu::ComplaintBasis.count }.from(1).to(2)
    expect(page.all('#siu_bases .siu_basis')[1].text).to eq "Another thing"
  end

  scenario "add gg complaint basis" do
    visit complaint_admin_path('en')
    sleep(0.1)
    expect(page).to have_selector '#gg_bases #empty'
    page.find('#gg_bases #gg_basis_name').set('A thing')
    expect{ new_gg_complaint_basis_button.click; wait_for_ajax }.to change{ GoodGovernance::ComplaintBasis.all.map(&:name) }.from([]).to(["A thing"])
    expect(page.find('#gg_bases .gg_basis').text).to eq "A thing"
    expect(page).not_to have_selector '#gg_bases #empty'
    page.find('#gg_bases #gg_basis_name').set('Another thing')
    expect{ new_gg_complaint_basis_button.click; wait_for_ajax }.to change{ GoodGovernance::ComplaintBasis.count }.from(1).to(2)
    expect(page.all('#gg_bases .gg_basis')[1].text).to eq "Another thing"
  end

  scenario "add duplicate complaint basis under same mandate" do
    GoodGovernance::ComplaintBasis.create(:name => "A thing")
    visit complaint_admin_path('en')
    sleep(0.1)
    page.find('#gg_bases #gg_basis_name').set('A thing')
    expect{ new_gg_complaint_basis_button.click; wait_for_ajax }.not_to change{ GoodGovernance::ComplaintBasis.count }
    expect( flash_message ).to eq "Complaint basis already exists, must be unique."
  end

  scenario "add duplicate complaint basis under different mandate" do
    Siu::ComplaintBasis.create(:name => "A thing")
    visit complaint_admin_path('en')
    sleep(0.1)
    page.find('#gg_bases #gg_basis_name').set('A thing')
    expect{ new_gg_complaint_basis_button.click; wait_for_ajax }.to change{ GoodGovernance::ComplaintBasis.count }.by(1)
  end

  scenario "delete a siu complaint basis" do
    Siu::ComplaintBasis.create(:name => "A thing")
    visit complaint_admin_path('en')
    expect{ delete_complaint_basis("A thing").click; wait_for_ajax }.to change{ Siu::ComplaintBasis.count }.by -1
    expect(page).to have_selector '#siu_bases #empty'
  end

  scenario "delete a good governance complaint basis" do
    GoodGovernance::ComplaintBasis.create(:name => "A thing")
    visit complaint_admin_path('en')
    expect{ delete_complaint_basis("A thing").click; wait_for_ajax }.to change{ GoodGovernance::ComplaintBasis.count }.by -1
    expect(page).to have_selector '#gg_bases #empty'
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
    expect{ delete_complaint_basis("A thing").click; wait_for_ajax }.to change{ ComplaintCategory.count }.by -1
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
