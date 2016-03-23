class Nhri::FileMonitor < ActiveRecord::Base
  belongs_to :indicator
  belongs_to :author, :class_name => "User", :foreign_key => :author_id

  def as_json(options={})
    super(:except => [:updated_at, :created_at], :methods => [:url, :val, :author])
  end

  def url
    Rails.application.routes.url_helpers.nhri_indicator_monitor_path(:en,indicator.heading_id,indicator_id,id) if persisted?
  end
end
