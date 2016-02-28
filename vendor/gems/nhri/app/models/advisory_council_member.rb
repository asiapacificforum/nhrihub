class AdvisoryCouncilMember < ActiveRecord::Base
  def self.create_url
    Rails.application.routes.url_helpers.nhri_advisory_council_members_path(I18n.locale)
  end

  def url
    if persisted?
      Rails.application.routes.url_helpers.nhri_advisory_council_member_path(I18n.locale,'id')
    end
  end

  def as_json(options={})
    super(:except => [:created_at, :updated_at], :methods => :url)
  end
end
