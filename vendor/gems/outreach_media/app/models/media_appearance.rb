class MediaAppearance < ActiveRecord::Base
  belongs_to :violation_severity
  belongs_to :positivity_rating
  delegate :id, :text, :rank, :rank_text, :to => :positivity_rating, :prefix => true, :allow_nil => true
  delegate :id, :text, :rank, :rank_text, :to => :violation_severity, :prefix => true, :allow_nil => true
  belongs_to :user
  has_many :reminders, :as => :remindable, :dependent => :delete_all
  has_many :notes, :as => :notable, :dependent => :delete_all
  has_many :media_areas, :dependent => :destroy
  has_many :areas, :through => :media_areas
  has_many :media_subareas, :dependent => :destroy
  has_many :subareas, :through => :media_subareas

  attachment :file

  default_scope { order('created_at desc') }

  def self.maximum_filesize
    SiteConfig['outreach_media.filesize']*1000000
  end

  def self.permitted_filetypes
    SiteConfig['outreach_media.filetypes'].to_json
  end

  def as_json(options={})
    super({:except => [:updated_at,
                       :created_at,
                       :affected_people_count,
                       :violation_severity,
                       :violation_coefficient],
           :methods=> [:date,
                       :metrics,
                       :has_link,
                       :article_link,
                       :has_scanned_doc,
                       :media_areas,
                       :area_ids,
                       :subarea_ids,
                       :reminders,
                       :notes,
                       :create_reminder_url,
                       :create_note_url,
                       :url,
                       :attachment_url]})
  end

  def positivity_rating_rank=(val)
    self.positivity_rating_id = PositivityRating.where(:rank => val).first.id unless val.blank?
  end

  def violation_severity_rank=(val)
    self.violation_severity_id = ViolationSeverity.where(:rank => val).first.id unless val.blank?
  end

  def page_data
    MediaAppearance.all
  end

  def create_url
    Rails.application.routes.url_helpers.outreach_media_media_appearances_path(:en)
  end

  def create_note_url
    Rails.application.routes.url_helpers.outreach_media_media_appearance_notes_path(:en,id) if persisted?
  end

  def create_reminder_url
    Rails.application.routes.url_helpers.outreach_media_media_appearance_reminders_path(:en,id) if persisted?
  end

  def url
    Rails.application.routes.url_helpers.outreach_media_media_appearance_path(:en,id) if persisted?
  end

  def namespace
    :outreach_media
  end

  def date
    created_at.to_time.to_date.to_s(:default) if persisted? # to_time converts to localtime
  end

  def metrics
    MediaAppearanceMetrics.new(self)
  end

  def has_link
    !article_link.blank?
  end

  def has_scanned_doc
    !file_id.blank?
  end

  def violation_coefficient
    vc = read_attribute(:violation_coefficient)
    LocalMetric.new(vc, :media_appearance, :violation_coefficient)
  end

  def affected_people_count
    apc = read_attribute(:affected_people_count)
    LocalMetric.new(apc, :media_appearance, :affected_people_count)
  end
end
