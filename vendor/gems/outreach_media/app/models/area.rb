class Area < ActiveRecord::Base
  has_many :subareas, :dependent => :delete_all
  def as_json(opts = {})
    super(:except => [:created_at, :updated_at], :methods => :subareas)
  end
end
