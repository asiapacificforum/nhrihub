require 'rails_helper'
require 'login_helpers'
require_relative '../../helpers/headings/indicators_spec_helpers'
require_relative '../../helpers/headings/indicators_spec_setup_helpers'

feature "indicators behaviour", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include IndicatorsSpecHelpers
  include IndicatorsSpecSetupHelpers

  it "should delete indicators" do
    expect{delete_indicator.click; sleep(0.3)}.to change{Nhri::Indicator::Indicator.count}.by(-1)
    expect(page).not_to have_selector("#indicators .indicator")
  end

  it "should edit indicators" do
    expect(1).to eq 0
  end

end

