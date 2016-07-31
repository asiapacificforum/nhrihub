class ComplaintAgency < ActiveRecord::Base
  belongs_to :complaint
  belongs_to :agency
end
