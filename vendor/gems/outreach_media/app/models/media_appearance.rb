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
    SiteConfig['outreach_media.media_appearances.filesize']*1000000
  end

  def self.permitted_filetypes
    SiteConfig['outreach_media.media_appearances.filetypes'].to_json
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

  #{"id":54,
     #"file_id":"ea8dba7530e81e8d2ccb95b4f995d50e195c41065b7316ee4b4bbd929684",
     #"filesize":1408570,
     #"original_filename":"Men of Cylink.pdf",
     #"original_type":"application/pdf",
     #"user_id":1,
     #"url":"/en/outreach_media/media_appearances/54",
     #"title":"sdasdgadfgdafgadfgdaf",
     #"note":null,
     #"positivity_rating_id":1,
     #"reminder_id":null,
     #"violation_severity_id":null,
     #"lastModifiedDate":"2002-11-25T08:24:00.000Z",
     #"article_link":null,
     #"date":"November 20,
      #2015",
     #"metrics":{"positivity_rating":{"rank":1, "name":"Positivity rating", "value":"1: Reflects very negatively on the office", "id":1},
                 #"violation_severity":{"rank":null, "name":"Violation severity", "value":null, "id":null},
                 #"violation_coefficient":{"name":"Violation coefficient", "value":null},
                 #"affected_people_count":{"name":"# People affected", "value":null}},
     #"has_link":false,
     #"has_scanned_doc":true,
     #"media_areas":[{"area_id":1, "subarea_ids":[3]}, {"area_id":2, "subarea_ids":[8]}],
     #"area_ids":[1, 2],
     #"subarea_ids":[3, 8],
     #"reminders":[],
     #"notes":[],
     #"create_reminder_url":"/en/outreach_media/media_appearances/54/reminders",
     #"create_note_url":"/en/outreach_media/media_appearances/54/notes"}

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
end
