class ComplaintComplaintBasis < ActiveRecord::Base
  belongs_to :complaint
  belongs_to :siu_complaint_basis, :class_name => 'Siu::ComplaintBasis', :foreign_key => :complaint_basis_id
  belongs_to :good_governance_complaint_basis, :class_name => 'GoodGovernance::ComplaintBasis', :foreign_key => :complaint_basis_id
  belongs_to :human_rights_complaint_basis, :class_name => 'Convention', :foreign_key => :complaint_basis_id
end
