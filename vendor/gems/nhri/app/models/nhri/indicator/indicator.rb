class Nhri::Indicator::Indicator < ActiveRecord::Base
  belongs_to :offence
  belongs_to :heading

  scope :structural, ->{ where(:nature => "Structural") }
  scope :process, ->{ where(:nature => "Process") }
  scope :outcomes, ->{ where(:nature => "Outcomes") }
  scope :all_offences, ->{ where(:offence_id => nil) }
end
