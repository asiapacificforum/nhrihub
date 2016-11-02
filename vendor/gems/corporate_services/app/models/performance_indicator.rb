class PerformanceIndicator < ActiveRecord::Base
  include Rails.application.routes.url_helpers
  belongs_to :activity
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :notes, :as => :notable, :autosave => true, :dependent => :destroy
  has_many :media_appearance_performance_indicators, :dependent => :destroy
  has_many :media_appearances, :through => :media_appearance_performance_indicators
  has_many :outreach_event_performance_indicators, :dependent => :destroy
  has_many :outreach_events, :through => :outreach_event_performance_indicators
  has_many :project_performance_indicators, :dependent => :destroy
  has_many :projects, :through => :project_performance_indicators
  default_scope ->{ order(:index) }

  before_create do
    self.description = self.description.gsub(/^[^a-zA-Z]*/,'')
    self.index = StrategicPlanIndexer.new(self,activity).next
  end

  def as_json(options={})
    default_options = {:except =>  [:updated_at, :created_at],
                       :methods => [:indexed_description,
                                    :url,
                                    :indexed_target,
                                    :description_error,
                                    :reminders,
                                    :create_reminder_url,
                                    :notes,
                                    :outreach_event_titles,
                                    :media_appearance_titles,
                                    :project_titles,
                                    :create_note_url]}
    super(default_options)
  end

  def namespace
    :corporate_services
  end

  after_destroy do |performance_indicator|
    lower_indexes = PerformanceIndicator.
                      where(:activity_id => performance_indicator.activity_id).
                      select{|pi| pi >= self}
    lower_indexes.each{|pi| pi.decrement_index }
  end

  def <=>(other)
    self.index.split('.').map(&:to_i) <=> other.index.split('.').map(&:to_i)
  end

  def >=(other)
    [0,1].include?(self <=> other)
  end

  def increment_index_root
    ar = index.split('.')
    ar[0] = ar[0].to_i.succ.to_s
    new_index = ar.join('.')
    update_attribute(:index, new_index)
  end

  def decrement_index
    ar = index.split('.')
    new_suffix = ar.pop.to_i.pred.to_i
    ar << new_suffix
    new_index = ar.join('.')
    update_attribute(:index, ar.join('.'))
  end

  def decrement_index_prefix(new_prefix)
    ar = index.split('.')
    new_index = [new_prefix,ar[4]].join('.')
    update_attribute(:index, new_index)
  end

  def outreach_event_titles
    outreach_events.map(&:title)
  end

  def media_appearance_titles
    media_appearances.map(&:title)
  end

  def project_titles
    projects.map(&:title)
  end

  def create_note_url
    corporate_services_performance_indicator_notes_path(:en,id)
  end

  def create_reminder_url
    corporate_services_performance_indicator_reminders_path(:en,id)
  end

  def url
    corporate_services_activity_performance_indicator_path(:en,activity_id,id)
  end

  def notable_url(notable_id)
    corporate_services_performance_indicator_note_path('en',id,notable_id)
  end

  def remindable_url(remindable_id)
    corporate_services_performance_indicator_reminder_path('en',id,remindable_id)
  end

  # to include this attribute in json
  def description_error
    nil
  end

  def indexed_description
    if description.blank?
      ""
    else
      [index, description].join(' ')
    end
  end

  def indexed_target
    if target.blank?
      ""
    else
      [index, target].join(' ')
    end
  end

  def copy
    PerformanceIndicator.new(attributes.slice("index", "description", "target"))
  end
end
