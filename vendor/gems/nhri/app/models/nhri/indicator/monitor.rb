class Nhri::Indicator::Monitor < ActiveRecord::Base
  belongs_to :indicator
  belongs_to :author, :class_name => "User", :foreign_key => :author_id

  def as_json(options={})
    super(:except => [:updated_at, :created_at], :methods => [:url, :val, :author])
  end

  def url
    Rails.application.routes.url_helpers.nhri_indicator_indicator_monitor_path(:en,indicator_id,id) if persisted?
  end

  def val
    case format # either "percent", "int" or "text"
    when "percent"
      "#{description}: #{value}%"
    when "int"
      "#{description}: #{value}"
    else
      description
    end
  end

end
