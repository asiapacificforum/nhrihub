class PerformanceIndicator < ActiveRecord::Base
  include StrategicPlanIndex
  include Rails.application.routes.url_helpers
  belongs_to :activity
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :notes, :as => :notable, :autosave => true, :dependent => :destroy
  has_many :media_appearance_performance_indicators, :dependent => :destroy
  has_many :media_appearances, :through => :media_appearance_performance_indicators
  has_many :project_performance_indicators, :dependent => :destroy
  has_many :projects, :through => :project_performance_indicators

  def as_json(options={})
    default_options = {:except =>  [:updated_at, :created_at],
                       :methods => [:indexed_description,
                                    :url,
                                    :indexed_target,
                                    :description_error,
                                    :reminders,
                                    :create_reminder_url,
                                    :notes,
                                    :media_appearance_titles,
                                    :project_titles,
                                    :create_note_url]}
    super(default_options)
  end

  def namespace
    :corporate_services
  end

  def index_descendant
    []
  end

  def index_parent
    activity
  end

  def media_appearance_titles
    media_appearances.map{|ma| ma.slice(:title,:index_path)}
  end

  def project_titles
    projects.map{|p| p.slice(:title,:index_path)}
  end

  def index_url
    strategic_plan = activity.outcome.planned_result.strategic_priority.strategic_plan
    corporate_services_strategic_plan_url(:en, strategic_plan.id, {:host => SITE_URL, :protocol => 'https', :performance_indicator_id => id})
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

  def indexed_target
    if target.blank?
      ""
    else
      [index, target].join(' ')
    end
  end

  def dup
    PerformanceIndicator.new(attributes.slice("index", "description", "target"))
  end
end
