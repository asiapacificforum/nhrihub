require_relative './seed_data/area_test'
require_relative './seed_data/media_appearance_test'
require_relative './seed_data/outreach_event_test'
require_relative './seed_data/audience_type_test'
require_relative './seed_data/impact_rating_test'
require_relative './seed_data/advisory_council_issue_test'
class SeedData
  def self.initialize
    #AudienceTypeTest.populate_test_data
    AreaTest.populate_test_data
    MediaAppearanceTest.populate_test_data
    ImpactRatingTest.populate_test_data
    #OutreachEventTest.populate_test_data
    #AdvisoryCouncilIssueTest.populate_test_data
  end
end
