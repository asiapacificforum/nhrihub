class Nhri::Indicator < ActiveRecord::Base
  belongs_to :offence
  belongs_to :heading
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :notes, :as => :notable, :autosave => true, :dependent => :destroy
  has_many :numeric_monitors, :dependent => :destroy
  has_many :text_monitors, :dependent => :destroy
  has_one :file_monitor, :dependent => :destroy

  scope :structural, ->{ where(:nature => "Structural") }
  scope :process, ->{ where(:nature => "Process") }
  scope :outcomes, ->{ where(:nature => "Outcomes") }
  scope :all_offences, ->{ where(:offence_id => nil) }

  def as_json(options={})
    super(:except => [:created_at, :updated_at],
          :methods => [:notes,
                       :reminders]+monitor_methods)
  end

  def monitor_methods
    case monitor_format
    when "numeric"
      [:numeric_monitors]
    when "text"
      [:text_monitors]
    else
      [:file_monitor]
    end
  end

  def monitors
    case monitor_format
    when "numeric"
      numeric_monitors
    when "text"
      text_monitors
    else
      file_monitor
    end
  end

  def polymorphic_path
    OpenStruct.new(:prefix => 'nhri_indicator', :keys => {:indicator_id => id})
  end

end
