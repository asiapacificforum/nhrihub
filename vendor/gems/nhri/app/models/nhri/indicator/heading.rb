class Nhri::Indicator::Heading < ActiveRecord::Base
  has_many :offences
  has_many :indicators

  def self.create_url
    Rails.application.routes.url_helpers.nhri_headings_path(:en)
  end

  def url
    Rails.application.routes.url_helpers.nhri_heading_path(:en,id) if persisted?
  end

  def as_json(options={})
    super(:except  => [:created_at, :updated_at],
          :methods => [:url])
  end
end
