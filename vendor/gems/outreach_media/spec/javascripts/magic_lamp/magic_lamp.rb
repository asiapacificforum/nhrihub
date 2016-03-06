require_relative './seed_data'

SeedData.initialize


MagicLamp.define do
  # e.g. on page do this:  window.media_appearances = MagicLamp.loadJSON('collection_items')
  fixture(:name => 'collection_items') do
    SeedData.initialize
    MediaAppearance.all
  end

  fixture(:name => 'areas_data') do
    AreaTest.populate_test_data
    Area.all
  end

  fixture(:name => 'subareas_data') do
    AreaTest.populate_test_data
    Subarea.extended
  end

  fixture(:name => 'new_collection_item') do
    MediaAppearance.new
  end

  fixture(:name => 'create_collection_item_url') do
    MediaAppearance.new.create_url
  end

  fixture(:name => 'maximum_filesize') do
    OutreachEvent.maximum_filesize # shared by OutreachEvent and MediaAppearance
  end

  fixture(:name => 'permitted_filetypes') do
    OutreachEvent.permitted_filetypes # shared by OutreachEvent and MediaAppearance
  end

  fixture(:name => 'media_appearance_page') do
    @areas = Area.all
    render :partial => 'outreach_media/media_appearances/index'
  end

  fixture(:name => 'outreach_event_data') do
    ImpactRatingTest.populate_test_data
    AudienceTypeTest.populate_test_data
    AreaTest.populate_test_data
    OutreachEventTest.populate_test_data
    OutreachEvent.all
  end

  fixture(:name => 'selected_audience_type') do
    "Select audience type"
  end

  fixture(:name => 'selected_impact_rating') do
    "Select impact rating"
  end

  fixture(:name => 'audience_types') do
    AudienceTypeTest.populate_test_data
    AudienceType.all
  end

  fixture(:name => 'new_outreach_event') do
    OutreachEvent.new
  end

  fixture(:name => 'create_outreach_event_url') do
    OutreachEvent.new.create_url
  end

  fixture(:name => 'outreach_event_page') do
    render :partial => 'outreach_media/outreach_events/index'
  end

  fixture(:name => 'impact_ratings') do
    ImpactRatingTest.populate_test_data
    ImpactRating.all
  end
end
