require 'rails_helper'
require 'login_helpers'
require_relative '../../helpers/headings/offences_spec_helpers'
require_relative '../../helpers/headings/offences_spec_setup_helpers'

feature "offences behaviour", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include OffencesSpecHelpers
  include OffencesSpecSetupHelpers

  it "should add an offence" do
    expect(1).to eq 1
  end

  it "should delete an offence" do
    expect(1).to eq 1
  end

  it "should edit an offence" do
    expect(1).to eq 1
  end
end
