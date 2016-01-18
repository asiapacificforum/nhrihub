class MediaAppearancePerformanceIndicator < ActiveRecord::Base
  belongs_to :media_appearance
  belongs_to :performance_indicator
end
