require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../helpers/media_spec_helper'


feature "show media archive", :js => true do
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include MediaSpecHelpers

  before do
    setup_positivity_ratings
    FactoryGirl.create(:media_appearance, :positivity_rating => PositivityRating.first, :reminders=>[FactoryGirl.create(:reminder, :media_appearance)] )
    FactoryGirl.create(:media_appearance, :positivity_rating => PositivityRating.second, :reminders=>[FactoryGirl.create(:reminder, :media_appearance)] )
    FactoryGirl.create(:media_appearance, :positivity_rating => PositivityRating.third, :reminders=>[FactoryGirl.create(:reminder, :media_appearance)] )
    visit outreach_media_media_path(:en)
  end

  scenario "human rights description variable" do
    expect(page_heading).to eq "Media Archive"
    expect(page).to have_selector("#media_appearances .media_appearance", :count => 3)
  end

  scenario "subarea acronyms have tooltip showing long name" do
    expect(1).to eq 0
  end
end
