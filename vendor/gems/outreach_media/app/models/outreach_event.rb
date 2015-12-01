class OutreachEvent < ActiveRecord::Base
  belongs_to :impact_rating
  delegate :id, :text, :rank, :rank_text, :to => :impact_rating, :prefix => true, :allow_nil => true
  has_many :reminders, :as => :remindable, :dependent => :delete_all
  has_many :outreach_event_areas
  has_many :areas, :through => :outreach_event_areas
  has_many :outreach_event_documents

  def self.maximum_filesize
    SiteConfig['outreach_media.filesize']*1000000
  end

  def self.permitted_filetypes
    SiteConfig['outreach_media.filetypes'].to_json
  end

  def as_json(options={})
    super({:except => [:updated_at,
                       :created_at ],
           :methods=> [:date,
                       :metrics,
                       :article_link,
                       :media_areas,
                       :area_ids,
                       :subarea_ids,
                       :reminders,
                       :create_reminder_url,
                       :url ]})
  end

  def create_url
    Rails.application.routes.url_helpers.outreach_media_outreach_events_path(:en)
  end

end
