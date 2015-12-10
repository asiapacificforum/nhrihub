class Area < ActiveRecord::Base
  has_many :subareas, :dependent => :delete_all
  def as_json(opts = {})
    super(:except => [:created_at, :updated_at], :methods => [:subareas, :url])
  end

  def url
    Rails.application.routes.url_helpers.outreach_media_area_path(:en,id) if persisted?
  end
end
