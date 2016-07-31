class ComplaintGoodGovernanceComplaintBasis < ComplaintComplaintBasis
  belongs_to :good_governance_complaint_basis, :class_name => 'GoodGovernance::ComplaintBasis', :foreign_key => :complaint_basis_id
end
