class ComplaintMandate < ActiveRecord::Base
  belongs_to :complaint
  belongs_to :mandate
end
