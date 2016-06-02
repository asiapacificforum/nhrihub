class StatusChange < ActiveRecord::Base
  belongs_to :user
  belongs_to :complaint

  def as_json(options={})
    super(:only => [], :methods => [:user_name, :date, :status_humanized])
  end

  def user_name
    user.first_last_name
  end

  def date
    created_at.localtime.to_date.to_s(:short)
  end

  def status_humanized
    I18n.t(".activerecord.values.complaint.status.#{new_value}")
  end

  def status_humanized=(val)
    if val == "open"
      self.new_value = true
    else
      self.new_value = false
    end
  end

end
