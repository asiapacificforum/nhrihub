class Nhri::Indicator::Indicator < ActiveRecord::Base
  belongs_to :offence
  belongs_to :heading
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :notes, :as => :notable, :autosave => true, :dependent => :destroy
  has_many :monitors, :dependent => :destroy

  scope :structural, ->{ where(:nature => "Structural") }
  scope :process, ->{ where(:nature => "Process") }
  scope :outcomes, ->{ where(:nature => "Outcomes") }
  scope :all_offences, ->{ where(:offence_id => nil) }

  def as_json(options={})
    super(:except => [:created_at, :updated_at],
          :methods => [:url,
                       :notes,
                       :reminders,
                       :monitors,
                       :create_reminder_url,
                       :create_monitor_url,
                       :create_note_url])
  end

  def url
    Rails.application.routes.url_helpers.nhri_indicator_path(:en,id) if persisted?
  end

  def create_monitor_url
    Rails.application.routes.url_helpers.nhri_indicator_indicator_monitors_path(:en,id) if persisted?
  end

  def create_reminder_url
    Rails.application.routes.url_helpers.nhri_indicator_indicator_reminders_path(:en,id) if persisted?
  end

  def create_note_url
    Rails.application.routes.url_helpers.nhri_indicator_indicator_notes_path(:en,id) if persisted?
  end

  def namespace
    nil
  end

end
