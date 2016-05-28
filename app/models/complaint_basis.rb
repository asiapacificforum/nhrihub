class ComplaintBasis < ActiveRecord::Base
  def as_json(options = {})
    super(:only => [:id, :name])
  end
end
