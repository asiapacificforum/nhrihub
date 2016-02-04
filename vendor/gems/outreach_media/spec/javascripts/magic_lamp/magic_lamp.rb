require_relative './seed_data'

SeedData.initialize


MagicLamp.define do
  # e.g. on page do this:  window.media_appearances = MagicLamp.loadJSON('media_appearance_data')
  fixture(:name => 'media_appearance_data') do
    #SeedData.populate_media_appearances
    MediaAppearance.all
  end

  fixture(:name => 'areas_data') do
    Area.all
  end

  fixture(:name => 'subareas_data') do
    Subarea.extended
  end

  fixture(:name => 'new_media_appearance') do
    MediaAppearance.new
  end

  fixture(:name => 'create_media_appearance_url') do
    MediaAppearance.new.create_url
  end

  fixture(:name => 'maximum_filesize') do
    MediaAppearance.maximum_filesize
  end

  fixture(:name => 'permitted_filetypes') do
    MediaAppearance.permitted_filetypes
  end

  fixture(:name => 'media_appearance_page') do
    @areas = Area.all
    render :partial => 'outreach_media/media_appearances/index'
  end

  fixture(:name => 'outreach_event_data') do
    OutreachEvent.all
  end

  fixture(:name => 'selected_audience_type') do
    "Select audience type"
  end

  fixture(:name => 'selected_impact_rating') do
    "Select impact rating"
  end

  fixture(:name => 'audience_types') do
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
    ImpactRating.all
  end
end
