class Subarea < ActiveRecord::Base
  belongs_to :area
  def as_json(opts={})
    super(:except => [:created_at, :updated_at, :area_id], :methods => [:url])
  end

  def url
    Rails.application.routes.url_helpers.outreach_media_area_subarea_path(:en,area_id,id) if persisted?
  end

  def extended_name
    [area.name,name].join(" ")
  end

  def self.extended
    self.includes(:area).all.collect do |sa|
      sa.
        attributes.
        slice("id","name","full_name").
        merge({"extended_name" => sa.extended_name})
    end
  end

  def self.hr_violation_id
    joins(:area).where("subareas.name = 'Violation' and areas.name = 'Human Rights'").pluck(:id)[0]
  end
end
