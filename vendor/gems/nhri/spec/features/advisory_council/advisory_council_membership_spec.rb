require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/advisory_council/advisory_council_membership_spec_helper'
require_relative '../../helpers/advisory_council/advisory_council_membership_spec_setup_helper'


feature "index page", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include AdvisoryCouncilMembershipSpecHelper
  include AdvisoryCouncilMembershipSpecSetupHelper

  before do
    setup_membership_database
    visit nhri_advisory_council_members_path(:en)
  end

  it "shows lists media appearances" do
    expect(page.find('h1').text).to eq "Advisory Council Membership"
    expect(page.all('#members .member').count).to eq 3
  end

  it "should add a member" do
    page.find('#add_member').click
    wait_for_modal_open
    expect(page).to have_selector('#new_member_modal h4', :text => 'New advisory council member')
    fill_in("First name", :with => "Cathryn")
    fill_in("Last name", :with => "McKenzie")
    fill_in("Title", :with => "Director")
    fill_in("Email", :with => "elda@trantow.name")
    fill_in("Alternate email", :with => "griffin.reichert@williamson.info")
    fill_in("Biography", :with => Faker::Lorem.sentences(2).join(' '))
    fill_in("Organization", :with => "Some organization")
    fill_in("Department", :with => "Department of public affairs")
    expect{page.find('#save').click; wait_for_ajax}.to change{AdvisoryCouncilMember.count}.by(1)
    wait_for_modal_close
    expect(page).not_to have_selector('#new_member_modal')
    expect(page).to have_selector('#members .member .name', :text => 'Cathryn McKenzie')
    page.find('#add_member').click
    wait_for_modal_open
    expect(page).to have_selector('#new_member_modal h4', :text => 'New advisory council member')
    expect(page.find(:field, "First name").value).to be_blank
  end

  it "should delete a member" do
    expect{delete_first_member.click; confirm_deletion; wait_for_ajax }.to change{AdvisoryCouncilMember.count}.by(-1).
                                                  and change{page.all('#members .member').count}.by(-1)
  end

  it "should not add a member with a blank first name" do
    page.find('#add_member').click
    fill_in("Last name", :with => "McKenzie")
    expect{page.find('#save').click; wait_for_ajax}.not_to change{AdvisoryCouncilMember.count}
    expect(page).to have_selector('#first_name_error', :text => "First name can't be blank")
  end

  it "should not add a member with a blank last name" do
    page.find('#add_member').click
    expect(page).to have_selector('#new_member_modal h4', :text => 'New advisory council member')
    fill_in("First name", :with => "Cathryn")
    expect{page.find('#save').click; wait_for_ajax}.not_to change{AdvisoryCouncilMember.count}
    expect(page).to have_selector('#last_name_error', :text => "Last name can't be blank")
  end

  it "should clear the form when adding is canceled by closing the modal with the icon" do
    page.find('#add_member').click
    expect(page).to have_selector('#new_member_modal h4', :text => 'New advisory council member')
    fill_in("First name", :with => "Cathryn")
    fill_in("Last name", :with => "McKenzie")
    fill_in("Title", :with => "Director")
    fill_in("Email", :with => "elda@trantow.name")
    fill_in("Alternate email", :with => "griffin.reichert@williamson.info")
    fill_in("Biography", :with => Faker::Lorem.sentences(2).join(' '))
    fill_in("Organization", :with => "Some organization")
    fill_in("Department", :with => "Department of public affairs")
    modal_close_icon.click
    wait_for_modal_close
    page.find('#add_member').click
    expect(page).to have_selector('#new_member_modal h4', :text => 'New advisory council member')
    expect(page.find(:field, "First name").value).to be_blank
    expect(page.find(:field, "Last name").value).to be_blank
    expect(page.find(:field, "Title").value).to be_blank
    expect(page.find(:field, "Email").value).to be_blank
    expect(page.find(:field, "Alternate email").value).to be_blank
    expect(page.find(:field, "Biography").value).to be_blank
    expect(page.find(:field, "Organization").value).to be_blank
    expect(page.find(:field, "Department").value).to be_blank
  end

  it "should clear the form when adding is canceled by closing the modal by clicking cancel icon" do
    page.find('#add_member').click
    wait_for_modal_open
    expect(page).to have_selector('#new_member_modal h4', :text => 'New advisory council member')
    fill_in("First name", :with => "Cathryn")
    fill_in("Last name", :with => "McKenzie")
    fill_in("Title", :with => "Director")
    fill_in("Email", :with => "elda@trantow.name")
    fill_in("Alternate email", :with => "griffin.reichert@williamson.info")
    fill_in("Biography", :with => Faker::Lorem.sentences(2).join(' '))
    fill_in("Organization", :with => "Some organization")
    fill_in("Department", :with => "Department of public affairs")
    add_member_cancel_icon.click
    wait_for_modal_close
    page.find('#add_member').click
    wait_for_modal_open
    expect(page).to have_selector('#new_member_modal h4', :text => 'New advisory council member')
    expect(page.find(:field, "First name").value).to be_blank
    expect(page.find(:field, "Last name").value).to be_blank
    expect(page.find(:field, "Title").value).to be_blank
    expect(page.find(:field, "Email").value).to be_blank
    expect(page.find(:field, "Alternate email").value).to be_blank
    expect(page.find(:field, "Biography").value).to be_blank
    expect(page.find(:field, "Organization").value).to be_blank
    expect(page.find(:field, "Department").value).to be_blank
  end

  it "should save edited fields" do
    first_member_edit.click
    wait_for_modal_open
    id = AdvisoryCouncilMember.first.id
    expect(page).to have_selector("#edit_member#{id}_modal h4", :text => 'Edit advisory council member')
    new_bio = Faker::Lorem.sentences(2).join(' ')
    fill_in("First name", :with => "Letitia")
    fill_in("Last name", :with => "Effertz")
    fill_in("Title", :with => "Director")
    fill_in("Email", :with => "stanton.heel@bergnaum.net")
    fill_in("Alternate email", :with => "jimmie@stamm.net")
    fill_in("Biography", :with => new_bio)
    fill_in("Organization", :with => "Some organization")
    fill_in("Department", :with => "Department of public affairs")
    page.find('#save').click
    wait_for_ajax
    wait_for_modal_close
    advisory_council_member = AdvisoryCouncilMember.first
    expect(advisory_council_member.first_name).to eq "Letitia"
    expect(advisory_council_member.last_name).to eq "Effertz"
    expect(advisory_council_member.title).to eq "Director"
    expect(advisory_council_member.email).to eq "stanton.heel@bergnaum.net"
    expect(advisory_council_member.alternate_email).to eq "jimmie@stamm.net"
    expect(advisory_council_member.bio).to eq new_bio
    expect(advisory_council_member.organization).to eq "Some organization"
    expect(advisory_council_member.department).to eq "Department of public affairs"
    expect(page).not_to have_selector("#edit_member#{id}_modal")
    expect(page).to have_selector('#members .member .name', :text => "Letitia Effertz")
    expect(page).to have_selector('#members .member .email', :text => "stanton.heel@bergnaum.net")
    expect(page).to have_selector('#members .member .alternate_email', :text => "jimmie@stamm.net")
  end

  it "should restore values if edit is cancelled" do
    first_member_edit.click
    wait_for_modal_open
    advisory_council_member = AdvisoryCouncilMember.first
    id = advisory_council_member.id
    expect(page).to have_selector("#edit_member#{id}_modal h4", :text => 'Edit advisory council member')
    new_bio = Faker::Lorem.sentences(2).join(' ')
    fill_in("First name", :with => "Letitia")
    fill_in("Last name", :with => "Effertz")
    fill_in("Title", :with => "Director")
    fill_in("Email", :with => "stanton.heel@bergnaum.net")
    fill_in("Alternate email", :with => "jimmie@stamm.net")
    fill_in("Biography", :with => new_bio)
    fill_in("Organization", :with => "Some organization")
    fill_in("Department", :with => "Department of public affairs")
    page.find("#edit_member#{id}_modal #cancel")
    page.find('#cancel').click
    wait_for_modal_close
    expect(page).not_to have_selector("#edit_member#{id}_modal")
    expect(page).to have_selector('#members .member .name', :text => "#{advisory_council_member.first_name} #{advisory_council_member.last_name}")
    expect(page).to have_selector('#members .member .email', :text => advisory_council_member.email)
    expect(page).to have_selector('#members .member .alternate_email', :text => advisory_council_member.alternate_email)
    first_member_edit.click
    wait_for_modal_open
    advisory_council_member = AdvisoryCouncilMember.first
    expect(page.find('input#new_member_first_name').value).to eq advisory_council_member.first_name
  end
end
