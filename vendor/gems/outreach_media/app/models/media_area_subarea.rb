class MediaAreaSubarea < ActiveRecord::Base
  belongs_to :media_area
  belongs_to :subarea
end
