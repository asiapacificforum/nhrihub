class OutreachEventDocument < ActiveRecord::Base
  attachment :file
  def as_json(options = {})
    super({:except => [:updated_at, :created_at], :methods => [:url]})
  end

  def url
    Rails.
      application.
      routes.
      url_helpers.
      outreach_media_outreach_event_outreach_event_document_path(:en, outreach_event_id, id)
  end
end
