require 'rails_helper'
$:.unshift Complaints::Engine.root.join('spec', 'helpers')
require 'login_helpers'
require 'complaints_spec_setup_helpers'
require 'navigation_helpers'
require 'complaints_spec_helpers'

feature "complaints index", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include ComplaintsSpecSetupHelpers
  include NavigationHelpers
  include ComplaintsSpecHelpers

  before do
    populate_database
    visit complaints_path('en')
  end

  it "adds a new complaint that is valid" do
    add_complaint
    complete_required_fields
    expect{save_complaint.click; wait_for_ajax}.to change{ Complaint.count }.by(1)

    # on the server
    #puts "on server, first status change is:  #{ActiveRecord::Base.connection.execute('select change_date from status_changes').to_a.last["change_date"]}"
    #puts DateTime.now.strftime("%b %e, %Y")
    expect(first_complaint.find('#status_changes .status_change span.date').text).to eq Date.today.strftime("%b %-e, %Y")
  end
end

def complete_required_fields
  within new_complaint do
    fill_in('lastName', :with => "Normal")
    fill_in('firstName', :with => "Norman")
    fill_in('dob', :with => "08/09/1950")
    fill_in('village', :with => "Normaltown")
    fill_in('complaint_details', :with => "a long story about lots of stuff")
    check('special_investigations_unit')
    choose('complained_to_subject_agency_yes')
    check_basis(:good_governance, "Delayed action")
    select(User.staff.first.first_last_name, :from => "assignee")
  end
end
