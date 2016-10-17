class AdvisoryCouncilMember < ActiveRecord::Base
  def self.create_url
    Rails.application.routes.url_helpers.nhri_advisory_council_members_path(I18n.locale)
  end

  def as_json(options={})
    super(:except => [:created_at, :updated_at])
  end
end
