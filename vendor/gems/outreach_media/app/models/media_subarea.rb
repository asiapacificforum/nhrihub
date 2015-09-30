class MediaSubarea < ActiveRecord::Base
  belongs_to :media_appearance
  belongs_to :subarea
end
