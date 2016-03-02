class Nhri::AdvisoryCouncil::AdvisoryCouncilIssue < ActiveRecord::Base
  include FileConstraints
  ConfigPrefix = 'nhri.advisory_council_issue'
  attachment :file

  belongs_to :violation_severity
  belongs_to :positivity_rating
  delegate :text, :rank, :rank_text, :to => :positivity_rating, :prefix => true, :allow_nil => true
  delegate :text, :rank, :rank_text, :to => :violation_severity, :prefix => true, :allow_nil => true
  belongs_to :user
  has_many :reminders, :as => :remindable, :dependent => :delete_all
  has_many :notes, :as => :notable, :dependent => :delete_all
  has_many :issue_areas, :dependent => :destroy
  has_many :areas, :through => :issue_areas
  has_many :issue_subareas, :dependent => :destroy
  has_many :subareas, :through => :issue_subareas
end
