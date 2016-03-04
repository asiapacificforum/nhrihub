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

  def as_json(options={})
    super({:except => [:updated_at,
                       :created_at],
           :methods=> [:date,
                       :has_link,
                       :has_scanned_doc,
                       :collection_item_areas,
                       :area_ids,
                       :subarea_ids,
                       :positivity_rating_rank_text,
                       :reminders,
                       :notes,
                       :url,
                       :create_reminder_url,
                       :create_note_url,
                       :violation_severity_rank_text ]})
  end

  alias_method :collection_item_areas, :issue_areas

  def url
    Rails.application.routes.url_helpers.nhri_advisory_council_issue_path(:en,id) if persisted?
  end

  def create_url
    Rails.application.routes.url_helpers.nhri_advisory_council_issues_path(:en)
  end

  def create_note_url
    Rails.application.routes.url_helpers.nhri_advisory_council_advisory_council_issue_notes_path(:en,id) if persisted?
  end

  def create_reminder_url
    Rails.application.routes.url_helpers.nhri_advisory_council_advisory_council_issue_reminders_path(:en,id) if persisted?
  end

  def has_link
    false
  end

  def has_scanned_doc
    !file_id.blank?
  end

  def date
    created_at.to_time.to_date.to_s(:default) if persisted? # to_time converts to localtime
  end

  def namespace
    nil
  end

end
