require 'rails_helper'
require 'login_helpers'
require 'navigation_helpers'
require_relative '../../helpers/advisory_council/terms_of_reference_setup_helper'

feature "terms of reference document", :js => true do
  include IERemoteDetector
  include LoggedInEnAdminUserHelper # sets up logged in admin user
  include NavigationHelpers
  include AdvisoryCouncilTermsOfReferenceSetupHelper

  describe "list existing revisions" do
    before do
      setup_terms_of_reference_database
      visit nhri_advisory_council_terms_of_references_path('en')
    end

    it "should work" do
      expect(page.all('#terms_of_reference_versions .terms_of_reference_version').count).to eq 2
    end
  end

  describe "add a new revision" do
    before do
      visit nhri_advisory_council_terms_of_references_path('en')
    end

    it "should prepend the added revision" do
      page.attach_file("primary_file", upload_document, :visible => false)
      expect{upload_files_link.click; sleep(0.5)}.to change{TermsOfReferenceVersion.count}.from(0).to(1)
    end
  end
end
