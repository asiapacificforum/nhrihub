class Nhri::Indicator < ActiveRecord::Base
  # human_rights_attribute_id heading_id
  #    nil                       n       indicator belongs to a heading, and is associated with all attributes
  #     n                        n       indicator belongs to a particular attribute,
  #                                      heading_id included for routing after an indicator is created
  #                                      it is created in the context of an indicator
  belongs_to :human_rights_attribute
  belongs_to :heading
  has_many :reminders, :as => :remindable, :autosave => true, :dependent => :destroy
  has_many :notes, :as => :notable, :autosave => true, :dependent => :destroy
  has_many :numeric_monitors, :dependent => :destroy
  has_many :text_monitors, :dependent => :destroy
  has_one :file_monitor, :dependent => :destroy

  scope :structural, ->{ where(:nature => "Structural") }
  scope :process, ->{ where(:nature => "Process") }
  scope :outcomes, ->{ where(:nature => "Outcomes") }
  scope :all_attributes, ->{ where(:human_rights_attribute_id => nil) }

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
