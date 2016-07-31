class ComplaintComplaintCategory < ActiveRecord::Base
  belongs_to :complaint
  belongs_to :complaint_category
end
