class MediaArea < ActiveRecord::Base
  belongs_to :media_appearance
  belongs_to :area
  has_many :media_area_subareas, :dependent => :destroy
  has_many :subareas, :through => :media_area_subareas

  def as_json(opts = {})
    super(:except => [:id, :created_at, :updated_at, :media_appearance_id], :methods => :subarea_ids)
  end
end
