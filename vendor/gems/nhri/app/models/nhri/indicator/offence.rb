class Nhri::Indicator::Offence < ActiveRecord::Base
  belongs_to :heading
  has_many :indicators
  has_many :structural_indicators, ->{ where("nature = 'Structural'") }, :class_name => 'Nhri::Indicator::Indicator'
  has_many :process_indicators, ->{ where("nature = 'Process'") }, :class_name => 'Nhri::Indicator::Indicator'
  has_many :outcomes_indicators, ->{ where("nature = 'Outcomes'") }, :class_name => 'Nhri::Indicator::Indicator'
end
