class ComplaintComplaintBasis < ActiveRecord::Base
  belongs_to :complaint
  belongs_to :complaint_basis
  belongs_to :siu_complaint_basis, :foreign_key => :complaint_basis_id
  belongs_to :good_governance_complaint_basis, :foreign_key => :complaint_basis_id
end
