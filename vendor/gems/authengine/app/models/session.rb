class Session < ActiveRecord::Base
  belongs_to :user

  scope :belonging_to_user, ->(user) { where("user_id like ?", user) } # use % for wildcard
  scope :logged_in_after, ->(time) { where("(login_date >= ?) or logout_date is null", time) } # pass in a time object
  scope :logged_in_before, ->(time) { where("login_date <= ?", time) } # pass in a time object

  def self.create_or_update(*args)
    if previous_login = where({user_id:  args[0][:user_id], logout_date: nil}).last
      previous_login.update_attributes(session_id: args[0][:session_id])
      previous_login.reload
    else
      create(args[0])
    end
  end

  def formatted_login_date
    login_date.to_formatted_s(:date_and_time)
  end

  def formatted_logout_date
    logout_date ? logout_date.to_formatted_s(:date_and_time) : ""
  end
end
