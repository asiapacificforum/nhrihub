class OutreachEvent < ActiveRecord::Base
  belongs_to :impact_rating
  delegate :id, :text, :rank, :rank_text, :to => :impact_rating, :prefix => true, :allow_nil => true
  has_many :reminders, :as => :remindable, :dependent => :delete_all
  has_many :outreach_areas
  has_many :areas, :through => :outreach_areas
end
