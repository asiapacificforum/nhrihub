class OutreachEvent < ActiveRecord::Base
  belongs_to :impact_rating
  delegate :id, :text, :rank, :rank_text, :to => :impact_rating, :prefix => true, :allow_nil => true
  has_many :reminders, :as => :remindable, :dependent => :delete_all
  has_many :outreach_event_areas
  has_many :areas, :through => :outreach_event_areas
  has_many :outreach_event_subareas
  has_many :subareas, :through => :outreach_event_subareas
  has_many :outreach_event_documents
  belongs_to :audience_type

  delegate :rank, :to => :impact_rating, :prefix => true, :allow_nil => true

  def self.maximum_filesize
    SiteConfig['outreach_media.filesize']*1000000
  end

  def self.permitted_filetypes
    SiteConfig['outreach_media.filetypes'].to_json
  end

  def as_json(options={})
    super({:except => [:updated_at,
                       :created_at,
                       :event_date ],
           :methods=> [:date,
                       :outreach_event_areas,
                       :area_ids,
                       :subarea_ids,
                       :reminders,
                       :create_reminder_url,
                       :impact_rating_rank,
                       :url ]})
  end

  def create_url
    Rails.application.routes.url_helpers.outreach_media_outreach_events_path(:en)
  end

  def url
    Rails.application.routes.url_helpers.outreach_media_outreach_event_path(:en,id) if persisted?
  end

  def date
    if persisted? && event_date
      event_date.to_time.to_date.to_s(:default)  # to_time converts to localtime
    end
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
