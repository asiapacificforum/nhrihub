class PerformanceIndicator < ActiveRecord::Base
  belongs_to :activity
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :notes, :as => :notable, :autosave => true, :dependent => :destroy
  default_scope ->{ order(:id) } # this naturally orders by index

  before_save do
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
                                    :create_note_url]}
    super(default_options)
  end

  def namespace
    :corporate_services
  end

  def create_note_url
    Rails.application.routes.url_helpers.corporate_services_performance_indicator_notes_path(:en,id)
  end

  def create_reminder_url
    Rails.application.routes.url_helpers.corporate_services_performance_indicator_reminders_path(:en,id)
  end

  def url
    Rails.application.routes.url_helpers.corporate_services_activity_performance_indicator_path(:en,activity_id,id)
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
end
