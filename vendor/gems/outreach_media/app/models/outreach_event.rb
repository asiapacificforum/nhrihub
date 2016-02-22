class OutreachEvent < ActiveRecord::Base
  include FileConstraints
  ConfigPrefix = 'outreach_event'

  belongs_to :impact_rating
  delegate :text, :rank, :rank_text, :to => :impact_rating, :prefix => true, :allow_nil => true
  has_many :reminders, :as => :remindable, :dependent => :delete_all
  has_many :notes, :as => :notable, :dependent => :delete_all
  has_many :outreach_event_areas
  has_many :areas, :through => :outreach_event_areas
  has_many :outreach_event_subareas
  has_many :subareas, :through => :outreach_event_subareas
  has_many :outreach_event_documents, :dependent => :destroy
  belongs_to :audience_type
  has_many :outreach_event_performance_indicators, :dependent => :delete_all
  has_many :performance_indicators, :through => :outreach_event_performance_indicators

  delegate :rank, :to => :impact_rating, :prefix => true, :allow_nil => true

  def as_json(options={})
    super({:except => [:updated_at,
                       :created_at,
                       :event_date ],
           :methods=> [:date,
                       :outreach_event_areas,
                       :outreach_event_documents,
                       :area_ids,
                       :subarea_ids,
                       :performance_indicator_ids,
                       :reminders,
                       :notes,
                       :create_reminder_url,
                       :create_note_url,
                       :impact_rating_rank_text,
                       :url ]})
  end

  def create_url
    Rails.application.routes.url_helpers.outreach_media_outreach_events_path(:en)
  end

  def url
    Rails.application.routes.url_helpers.outreach_media_outreach_event_path(:en,id) if persisted?
  end

  def create_note_url
    Rails.application.routes.url_helpers.outreach_media_outreach_event_notes_path(:en,id) if persisted?
  end

  def create_reminder_url
    Rails.application.routes.url_helpers.outreach_media_outreach_event_reminders_path(:en,id) if persisted?
  end

  # date is stored in as UTC
  # client delivers the value in the local (client) time zone
  # and converts the database value to the local (client) time zone
  def date
    event_date.to_datetime.to_s if event_date # not sure why it's retrieved as an instance of Time, it should be DateTime, so convert it as a workaround
  end

  def date=(date)
    write_attribute(:event_date, DateTime.parse(date).utc)
  end

  def namespace
    :outreach_media
  end

  #def metrics
    #OutreachEventMetrics.new(self)
  #end

  #def description
    #d = read_attribute(:description)
    #LocalMetric.new(d, :outreach_event, :description)
  #end

  #def description=(obj)
    #write_attribute(:description, obj[:val]) if obj
  #end

  #def affected_people_count
    #apc = read_attribute(:affected_people_count)
    #LocalMetric.new(apc, :outreach_event, :affected_people_count)
  #end

  #def affected_people_count=(obj)
    #write_attribute(:affected_people_count, obj[:val]) if obj
  #end

  #def audience_name
    #an = read_attribute(:audience_name)
    #LocalMetric.new(an, :outreach_event, :audience_name)
  #end

  #def audience_name=(obj)
    #write_attribute(:audience_name, obj[:val]) if obj
  #end

  #def participant_count
    #pc = read_attribute(:participant_count)
    #LocalMetric.new(pc, :outreach_event, :participant_count)
  #end

  #def participant_count=(obj)
    #write_attribute(:participant_count, obj[:val]) if obj
  #end
end
