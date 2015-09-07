class Subarea < ActiveRecord::Base
  belongs_to :area
  def as_json(opts={})
    super(:except => [:created_at, :updated_at, :area_id])
  end
end
