class Nhri::Indicator < ActiveRecord::Base
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
    Rails.application.routes.url_helpers.nhri_heading_indicator_path(:en,heading_id,id) if persisted?
  end

  def create_monitor_url
    Rails.application.routes.url_helpers.nhri_heading_indicator_monitors_path(:en,heading_id,id) if persisted?
  end

  def create_reminder_url
    Rails.application.routes.url_helpers.nhri_heading_indicator_reminders_path(:en,heading_id,id) if persisted?
  end

  def create_note_url
    Rails.application.routes.url_helpers.nhri_heading_indicator_notes_path(:en,heading_id,id) if persisted?
  end

  def polymorphic_path
    OpenStruct.new(:prefix => 'nhri_heading_indicator', :keys => {:heading_id => heading_id, :indicator_id => id})
  end

end
