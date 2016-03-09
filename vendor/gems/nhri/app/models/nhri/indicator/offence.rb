class Nhri::Indicator::Offence < ActiveRecord::Base
  belongs_to :heading
  has_many :indicators
end
