class ComplaintStatus < ActiveRecord::Base
  has_many :status_changes
end
