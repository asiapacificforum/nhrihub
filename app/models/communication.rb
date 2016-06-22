class Communication < ActiveRecord::Base
  belongs_to :complaint
  belongs_to :user

  def as_json(options = {})
    super(:methods => [ :user ])
  end
end
